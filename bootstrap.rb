#! /usr/bin/env ruby

require 'time'

class OsxBootstrapper

    def main
        @@home = ENV.fetch('HOME')
        intro
        backup
    end

    def backup
        Interface.h2 'Preparations'
        Interface.pre Content::PREPARATIONS
        Interface.confirm? 'Go on'
        [@@home + '/.bashrc', @@home + '/.bash_profile'].each do |filename|
            basename = File.basename filename
            dirname = File.dirname filename
            time = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
            backupbase = basename + '.backup.' + time
            backupfile = dirname + '/' + backupbase 
            if File.exist? filename
                Interface.h3 'Preparations: ' + basename
                Interface.pre '
        A file "' + filename + '" is existing.
        I want to rename it to "' + backupbase + '".

        Enter stop to quit bootstrapping.
                '
                answer = Interface.query? ('Rename ' + basename + ' -> ' + backupbase + '?'), [:yes, :stop], :yes
                exit if answer == :stop
                puts 'Moving ' + filename + ' to ' + backupfile if answer == :yes
                Interface.confirm? 
            end
        end
    end

    def intro
        Interface.h1 'The Zen Path of Bootstrapping'
        Interface.pre Content::INTRO_TEXT
        Interface.confirm? 
        Interface.h2 'Me'
        Interface.pre Content::ABOUT_ME
        Interface.confirm?
        Interface.h2 'Lord'
        Interface.pre Content::ABOUT_LORD
        Interface.confirm?
    end

end

module Interface

    def self.pre text
        puts text
    end

    def self.h1 title
        self.h title, '+'
    end

    def self.h2 title
        self.h title, '-'
    end

    def self.h3 title
        self.h title, '.'
    end

    def self.h title, char
        width = 80
        system "clear"
        puts
        puts
        puts
        puts char * width
        puts (' ' * ((width - title.length)/2)) << title
        puts char * width
        puts
    end

    def self.confirm? question = '' 
        puts "    " << question << "\t\tHit [ENTER]"
        gets.chomp
    end

    def self.no_yes? question
        query? question, [:yes, :no], :no
    end

    def self.yes_no? question
        query? question, [:yes, :no], :yes
    end

    def self.query? question, options, default
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

module Content

    INTRO_TEXT = '
    The Bootstrapper will install basic software:

        * Homebrew
        * Ansible

    After doing this common setup it offers you to additionally
    install two admin tools.

        * Me
        * Lord
    '

    ABOUT_ME = '
    Me - Maintain software and dotfiles

    Me enables you to manage your local software setup by
    the use of an Ansible Playbook. This Playbook is already
    prepared to maintain a reasonable basic software suite
    and ready to be customized to suit your personal needs.

    Me enables you to maintain your dotfiles in a central 
    git repository like Github to make them accessible from 
    multiple machines. 
    
    This repository can also reside on a personal USB stick.
    '

    ABOUT_LORD = '
    Lord - Rule them all

    One Ring to rule them all, One Ring to find them, 
    One Ring to bring them all, and in the darkness bind them, 
    In the Land of Mordor where the Shadows lie. 
                                                    (Tolkien)

    Lord aims to be the master tool of admin tools. 
    It rules them as modules. Modules can be Homebrew 
    or Me. Just like Homebrew manages software compilation 
    in a unified manner Lord manages admin tools.
    '

    PREPARATIONS = '
    To set up a clean environment for bootstrapping
    very few preparations are required now. 

    I will backup "~/.bash_profile" and "~/.bashrc" for you.
    You will have to give your confirmation in each step.
    '

end

OsxBootstrapper.new.main

