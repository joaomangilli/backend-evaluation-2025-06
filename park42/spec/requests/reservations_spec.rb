require 'rails_helper'

RSpec.describe "POST /reservations", type: :request do
  let(:user) { session.user }
  let(:session) { create(:session) }
  let(:headers) do
    {
      'Authorization' => "Bearer #{session.token}",
      'Content-Type' => 'application/json'
    }
  end

  let(:start_at) { 5.days.from_now }
  let(:end_at) { 10.days.from_now }
  let(:amount) { 50_000 }
  let(:price_token) { PriceToken.generate(start_at:, end_at:, price: amount, currency: 'BRL') }
  let(:payment_token) { 'payment_token_123' }
  let(:payment_url) { 'http://example.com' }
  let(:payment_response) { double(success?: payment_response_success?, body: payment_response_body) }
  let(:payment_response_success?) { true }
  let(:payment_response_body) { {} }
  let(:max_spots) { '5000' }

  let(:params) do
    {
      price_token:,
      payment_token:,
      start_at: start_at.try(:iso8601),
      end_at: end_at.try(:iso8601),
      amount:
    }.to_json
  end

  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }

  before do
    allow(RestClient).to receive(:post).and_return(payment_response)
    allow(UpdateReservationStatusJob).to receive(:perform_in)

    ENV["PAYMENT_URL"] = payment_url
    ENV["MAX_SPOTS"] = max_spots
  end

  describe 'successful reservation creation' do
    let(:reservation) { Reservation.last }
    let(:reservation_dates) { ReservationDate.where(reservation_at: start_at..end_at, reservation_count: 1) }

    it 'returns 201' do
      post('/reservations', params:, headers:)

      expect(response).to have_http_status(:created)
    end

    it 'returns the created reservation data' do
      post('/reservations', params:, headers:)

      expect(response_body).to include(
        user_id: user.id,
        price_token:,
        payment_token:,
        amount:,
        status: 'pending'
      )
    end

    it 'creates a reservation in the database' do
      post('/reservations', params:, headers:)

      expect(reservation.user_id).to eq(user.id)
      expect(reservation.price_token).to eq(price_token)
      expect(reservation.payment_token).to eq(payment_token)
      expect(reservation.amount).to eq(amount)
      expect(reservation.start_at.to_date).to eq(start_at.to_date)
      expect(reservation.end_at.to_date).to eq(end_at.to_date)
      expect(reservation.pending?).to be_truthy
    end

    it 'creates the reservation dates' do
      post('/reservations', params:, headers:)

      expect(reservation_dates.count).to eq(6)
    end

    it 'creates the payment' do
      expect(RestClient).to receive(:post).with(
        url: "#{payment_url}/payments",
        payload: {
          payment_token:,
          amount:,
          reservation_id: anything
        }
      )

      post('/reservations', params:, headers:)
    end

    it 'expires the reservation in 15 minutes' do
      allow(UpdateReservationStatusJob).to receive(:perform_in).and_call_original

      post('/reservations', params:, headers:)

      expect(reservation.expired?).to be_truthy
      expect(reservation_dates.count).to eq(0)
    end
  end

  describe 'validation errors' do
    before { post('/reservations', params:, headers:) }

    context 'when price_token is missing' do
      let(:price_token) { nil }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Invalid price token")
      end
    end

    context 'when price_token is invalid' do
      let(:price_token) { PriceToken.generate(start_at:, end_at:, price: 40, currency: 'BRL') }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Invalid price token")
      end
    end

    context 'when the reservation is duplicated' do
      it 'returns 201' do
        post('/reservations', params:, headers:)

        expect(response).to have_http_status(:created)
      end

      it 'returns the reservation data' do
        post('/reservations', params:, headers:)

        expect(response_body).to include(
          user_id: user.id,
          price_token:,
          payment_token:,
          amount:,
          status: 'pending'
        )
      end

      it 'does not create a new reservation' do
        expect { post('/reservations', params:, headers:) }.not_to change(Reservation, :count)
      end
    end

    context 'when payment_token is missing' do
      let(:payment_token) { nil }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Payment token can't be blank")
      end
    end

    context 'when start_at is missing' do
      let(:start_at) { nil }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Start at can't be blank")
      end
    end

    context 'when start_at is not a datetime' do
      let(:start_at) { 'not_a_datetime' }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Start at can't be blank")
      end
    end

    context 'when start_at is greater than 3 months from now' do
      let(:start_at) { 4.months.from_now }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to include("Start at must be less than")
      end
    end

    context 'when start_at is greater than ends_at' do
      let(:start_at) { 1.months.from_now }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to include("End at must be greater than or equal to")
      end
    end

    context 'when start_at is less than today' do
      let(:start_at) { 1.day.ago }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to include("Start at must be greater than or equal to")
      end
    end

    context 'when end_at is missing' do
      let(:end_at) { nil }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("End at can't be blank")
      end
    end

    context 'when end_at is not a datetime' do
      let(:end_at) { 'not_a_datetime' }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("End at can't be blank")
      end
    end

    context 'when end_at is greater than 3 months from now' do
      let(:end_at) { 4.months.from_now }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to include("End at must be less than")
      end
    end

    context 'when amount is missing' do
      let(:amount) { nil }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Amount is not a number")
      end
    end

    context 'when amount is less than zero' do
      let(:amount) { -4 }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to eq("Amount must be greater than 0")
      end
    end
  end

  context 'parking spots' do
    let(:reservation) { Reservation.last }

    context 'when there is no spots' do
      before do
        create(:reservation_date, reservation_at: start_at.to_date, reservation_count: 2)

        post('/reservations', params:, headers:)
      end

      let(:reservation_date) { ReservationDate.last }
      let(:max_spots) { '2' }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body[:error]).to include("No available parking spots")
      end

      it 'does not create a reservation' do
        expect(reservation).to be_nil
      end

      it 'does not create a reservation date' do
        expect(reservation_date.reservation_count).to eq(2)
      end

      it 'does not call the payment API' do
        expect(RestClient).not_to receive(:post)
      end
    end

    context 'with a lot of reservation dates' do
      before do
        create(:reservation_date, reservation_at: 4.days.from_now.to_date, reservation_count: 4)
        create(:reservation_date, reservation_at: 30.days.from_now.to_date, reservation_count: 1)
        create(:reservation_date, reservation_at: 8.days.from_now.to_date, reservation_count: 2)
        create(:reservation_date, reservation_at: 11.days.from_now.to_date, reservation_count: 5)

        post('/reservations', params:, headers:)
      end

      let(:start_at) { 2.days.from_now }
      let(:end_at) { 15.days.from_now }

      context 'when there is no spots' do
        let(:max_spots) { '5' }

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:error]).to include("No available parking spots")
        end
      end

      context 'when there is spots' do
        let(:max_spots) { '6' }

        it 'returns 201' do
          expect(response).to have_http_status(:created)
        end
      end
    end

    context 'race condition' do
      context 'when reservation dates are created concurrently' do
        before do
          allow(ReservationDate).to receive(:find_or_initialize_by).and_raise(ActiveRecord::RecordNotUnique)

          post('/reservations', params:, headers:)
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:error]).to include("We could not create the reservation for the given range. Please try again.")
        end

        it 'does not create a reservation' do
          expect(reservation).to be_nil
        end

        it 'does not call the payment API' do
          expect(RestClient).not_to receive(:post)
        end
      end

      context 'when reservation dates are updated concurrently' do
        before do
          allow(ReservationDate).to receive(:find_or_initialize_by).and_raise(ActiveRecord::StaleObjectError)

          post('/reservations', params:, headers:)
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body[:error]).to include("We could not create the reservation for the given range. Please try again.")
        end

        it 'does not create a reservation' do
          expect(reservation).to be_nil
        end

        it 'does not call the payment API' do
          expect(RestClient).not_to receive(:post)
        end
      end
    end
  end

  context 'payment' do
    let(:reservation) { Reservation.last }

    context 'when the payment API returns an error' do
      before { allow(RestClient).to receive(:post).and_raise(RestClient::Error) }

      it 'raises a CreatePaymentService::Error' do
        expect { post('/reservations', params:, headers:) }.to raise_error(CreatePaymentService::Error)
      end
    end

    context 'when the payment API returns an unsuccefull message' do
      let(:payment_response_success?) { false }
      let(:payment_response_body) { { errors: [ payment_response_body_error ] } }
      let(:payment_response_body_error) { 'Payment failed' }

      it 'logs the error and fails the reservation' do
        expect(Rails.logger).to receive(:error).with(payment_response_body_error)

        post('/reservations', params:, headers:)

        expect(reservation.failed?).to be_truthy
      end
    end
  end

  describe 'authentication' do
    before { post('/reservations', params:, headers:) }

    context 'when no authorization header is provided' do
      let(:headers) { { 'Content-Type' => 'application/json' } }

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when invalid token is provided' do
      let(:headers) do
        {
          'Authorization' => "Bearer wrong",
          'Content-Type' => 'application/json'
        }
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
