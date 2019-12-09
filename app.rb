require 'dotenv/load'
require 'discordrb'
require 'redd'

CACHE_SEMAPHORE = Mutex.new
CACHE = []
def cache!
  CACHE_SEMAPHORE.synchronize do
    CACHE.sample
  end
end

REDDIT = Redd.it(user_agent: "Redd:FloridaMan:19.8.10 (by /u/#{ENV['FLORIDA_MAN_USERNAME']})", client_id: ENV['FLORIDA_MAN_CLIENTID'], secret: ENV['FLORIDA_MAN_SECRETID'], username: ENV['FLORIDA_MAN_USERNAME'], password: ENV['FLORIDA_MAN_PASSWORD'])
FLORIDA_MAN_REGEX = /^florida man/i
Thread.new(REDDIT) do |session|
  session.subreddit('FloridaMan').post_stream.each do |post|
    next if not post.title.match? FLORIDA_MAN_REGEX
    CACHE_SEMAPHORE.synchronize do
      CACHE.push(post.title.gsub(FLORIDA_MAN_REGEX, '').strip)
    end
  end
end

BOT = Discordrb::Bot.new(token: ENV['FLORIDA_MAN_TOKEN'])
BOT.mention do |event|
  event.respond("_#{cache!}_")
  event.message.delete
end
BOT.run