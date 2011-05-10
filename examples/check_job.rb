require File.dirname(__FILE__) + "/common"

# 5. client calls to check if it is done.
@job_ids = @redis.SMEMBERS(@keys[:user_jobs])
@job_ids.each do |job_id|  
  status_key = interpolate_job_id(@keys[:job_status], job_id)
  job_key    = interpolate_job_id(@keys[:user_job], job_id)
  status     = @redis.HGET(status_key, :perc)

  puts "Job ##{job_id} status: #{status}"
  
  if status.to_i == 100
    # rebuild connection
    conn = Marshal.load(@redis.GET(job_key))

    # connect
    conn.attach
    
    # echo result
    puts conn.eval("x").to_ruby
    
    # remove job from set of user jobs
    @redis.SREM(@keys[:user_jobs], job_id)
    
    # destroy status hash
    @redis.DEL(status_key)
    
    # destroy marshalled connection
    @redis.DEL(job_key)    
    
    # note to user
    puts "job completed"
  end  
end