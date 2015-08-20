#! /usr/bin/env ruby

class OsxBootstrapper

    def main
        puts 'Work in progress'
        confirm? 'Please come back later!'
    end

    def confirm? question
        query? question, [ 'ENTER' ], 'ENTER' 
    end

    def no_yes? question
        query? question, [:yes, :no], :no
    end

    def yes_no? question
        query? question, [:yes, :no], :yes
    end

    def query? question, options, default
        displayed_options = options.map { |option| 
            if option == default then
                option = option.to_s.capitalize 
            end
            option.to_s
        }
        puts
        puts question << ' (' << displayed_options.join('/') << ')'
        result = nil
        until result
            answer = gets.chomp
            answer = answer.empty? ? default.to_s : answer
            result = options.select { |option| 
                option.to_s[0,1].capitalize == answer[0,1].capitalize
            }.first
            puts 'Please answer with one of: ' << 
                options.map{|o|o.to_s[0,1]}.join(', ') unless result
                
        end
        result
    end

end

OsxBootstrapper.new.main

