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

REDDIT = Redd.it(user_agent: "Redd:FloridaMan:19.8.10 (by /u/#{ENV['REDDIT_USERNAME']})", client_id: ENV['REDDIT_CLIENTID'], secret: ENV['REDDIT_SECRETID'], username: ENV['REDDIT_USERNAME'], password: ENV['REDDIT_PASSWORD'])
FLORIDA_MAN_REGEX = /^florida man/i
Thread.new(REDDIT) do |session|
  session.subreddit('FloridaMan').post_stream.each do |post|
    next if not post.title.match? FLORIDA_MAN_REGEX
    CACHE_SEMAPHORE.synchronize do
      CACHE.push(post.title.gsub(FLORIDA_MAN_REGEX, '').strip)
    end
  end
end

BOT = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
BOT.mention do |event|
  event.respond("_#{cache!}_")
  event.message.delete
end
BOT.run