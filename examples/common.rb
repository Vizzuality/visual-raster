require 'yaml'
require 'rserve'
require 'redis'
require File.dirname(__FILE__) + "/hash_ext"

CONFIG = YAML.load_file('../config/config.yml')
CONFIG.symbolize_keys! && CONFIG[:server].symbolize_keys!
@con = Rserve::Connection.new(CONFIG[:server])
@redis = Redis.new

@user_id = 1
@keys = {
  :job_pk => "r:users:#{@user_id}:job_pk", 	              #- KvP  => 0..n (incrementing key)
  :user_jobs => "r:users:#{@user_id}:jobs",   	          #- Set => {1,2,3,4,5...} (job_pks)
  :user_job => "r:users:#{@user_id}:jobs:{{job_id}}",	    #- KvP  => serialised rserve connection object (add job id)
  :job_status => "r:jobs:{{job_id}}:status", 	            #- Hash => {:err => "", :status => "", :perc => 0..100}
}

def interpolate_job_id(key, id)
  key.gsub(/{{job_id}}/, id.to_s)
end