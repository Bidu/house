class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  def connection_ok?
    execute('show tables')
    true
  rescue ::Mysql2::Error
    false
  end
end
