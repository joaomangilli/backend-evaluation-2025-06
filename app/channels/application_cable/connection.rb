module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        token = request.params[:token]
        auth = request.headers["Authorization"].to_s
        token ||= auth.delete_prefix("Bearer ").strip if auth.start_with?("Bearer ")
        if token.present? && (session = Session.find_by(token: token))
          self.current_user = session.user
        end
      end
  end
end
