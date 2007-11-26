class SessionCleaner
  def self.remove_stale_sessions(time_limit=60)
    CGI::Session::ActiveRecordStore::Session.
      destroy_all( ['updated_at <?', time_limit.minutes.ago] ) 
  end
end