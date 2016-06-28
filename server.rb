require "sinatra"
require 'open-uri'
require 'csv'

get '/' do
  departures = CSV.parse(open("http://developer.mbta.com/lib/gtrtfs/Departures.csv"), headers: :first_row).to_a

  headers = departures.shift
  headers.shift  # remove timestamp column
  headers[3] = "Scheduled Time"
  headers[4] = "Actual Time"

  timestamp = departures[0][0]
  time = Time.at(timestamp.to_i).strftime("%l:%M:%S%P")

  departures.each do |row|
    row.shift  # remove timestamp
    actual_time = Time.at(row[3].to_i + row[4].to_i).strftime("%l:%M%P")
    row[4] = actual_time
    row[3] = Time.at(row[3].to_i).strftime("%l:%M%P")
  end

  erb :board, locals: { departures: departures, headers: headers, time: time }
end
