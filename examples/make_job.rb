require File.dirname(__FILE__) + "/common"

# 1. Redis has a primary key store
@pk = @redis.INCR @keys[:job_pk]

# 2. All R calls from Ruby include primary key as the first argument
@con.eval("x<-vr.example.2(#{@pk},2,2)")

# 3. R call is disconnected as soon as it is made, and the connection is serialised into redis in a set specific to a user_id
s=@con.detach
connection = Marshal.dump(s)
@redis.SET(interpolate_job_id(@keys[:user_job], @pk), connection)
@redis.SADD(@keys[:user_jobs], @pk)

# 4. job done and posted to R.
puts "job made: #{@pk}"