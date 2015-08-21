#! /usr/bin/env ruby

require 'time'

class MeLordBootstrapper

    def main
        @timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
        intro
        interview
        backup
        reconfigure
        homebrew
        ansible
        report
    end

    def intro
        Interface.h1 'The Zen Path of Bootstrapping'
        Interface.pre Content::INTRO_TEXT
        Interface.confirm? 
        Interface.h2 'Me'
        Interface.pre Content::ABOUT_ME
        @install_me = Interface.yes_no? 'Do you want to install *Me*?'
        Interface.h2 'Lord'
        Interface.pre Content::ABOUT_LORD
        @install_lord = Interface.yes_no? 'Do you want to install Lord?'
    end

    def interview
        Interface.h2 'Customization'
        Interface.pre Content::HOMEBREW_CUSTOMIZING
        @homebrew_taste = Interface.query? 'Select your installation type', [:home, :library, :user], :home 
        if @install_lord == :yes then
            Interface.pre Content::LORD_CUSTOMIZING
            @lord_taste = Interface.query? 'Select your installation type', [:home, :library, :user], :home 
        end
        if @install_me == :yes then
            Interface.pre Content::ME_CUSTOMIZING
            @me_taste = Interface.query? 'Select your installation type', [:home, :library, :user], :home 
        end
    end

    def backup
        home = ENV.fetch('HOME')
        Interface.h2 'Preparations'
        Interface.pre Content::PREPARATIONS
        Interface.confirm? 'Go on'
        [home + '/.bashrc', home + '/.bash_profile'].each do |filename|
            basename = File.basename filename
            dirname = File.dirname filename
            backupbase = basename + '.backup.' + @timestamp
            backupfile = dirname + '/' + backupbase 
            if File.exist? filename
                Interface.h3 'Preparations: ' + basename
                Interface.pre sprintf(Content::BACKUPINFO, filename, backupbase) 
                answer = Interface.query? ('Rename ' + basename + ' -> ' + backupbase + '?'), [:yes, :stop], :yes
                fatal 'STOP', 'You stopped bootstrapping.' if answer == :stop
                begin
                    File.rename filename, backupfile
                    Interface.success 'Moving ' + filename + "\n to " + backupfile 
                rescue SystemCallError
                    fatal 'Moving ' + filename + "\n to " + backupfile 
                end
                Interface.confirm? 
            end
        end
    end

    def reconfigure
    end

    def homebrew
    end
    
    def ansible
    end

    def report
    end

    def fatal title, text
        Interface.fatal title, text
        exit
    end

end

class String
    def red! 
        replace "\033[1;31m" + self + "\033[0m"
    end

    def green! 
        replace "\033[1;32m" + self  + "\033[0m"
    end

    def yellow!
        replace "\033[1;33m" +  self + "\033[0m"
    end

    def blue!
        replace "\033[1;34m" + self + "\033[0m"
    end

end

module Interface

    def self.success title, text = nil
        self.bullet :success, title, text
    end

    def self.warn title, text = nil
        self.bullet :warn, title, text
    end

    def self.error title, text = nil
        self.bullet :error, title, text
    end

    def self.fatal title, text = nil
        self.bullet :error, 'Fatal: ' + title, text
    end

    def self.bullet(status, title , text = NIL)
        prefixes = {} 
        prefixes[:success] = "\t\033[1;32m✔ "
        prefixes[:warn]    = "\t\033[1;33m➜ "
        prefixes[:error]   = "\t\033[1;31m✖ "
        puts prefixes[status] << title << "\033[0m" 
        puts "\t" << text if text
    end

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
        puts (' ' * ((width - title.length)/2)) << title.red!
        puts char * width
        puts
    end

    def self.confirm? question = '' 
        if question.empty? then
            puts ' ➜  Hit ' + '[ENTER]'.green!
        else
            puts "   " << question << " ➜  Hit " + "[ENTER]".green!
        end
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
                option = option.to_s.capitalize.green!
            end
            option.to_s
        }
        puts
        puts " ➜   " + question << ' (' << displayed_options.join('/') << ')'
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
    I will install this basic software:

        ✔ Homebrew
        ✔ Ansible

    I offer you the possibility to install two optional admin tools:

        ✔ Me
        ✔ Lord
    '

    ABOUT_ME = '
    Me - Maintain software and dotfiles

    Me enables you to manage your local software setup by
    the use of an Ansible Playbook. This Playbook is already
    prepared to maintain a reasonable basic software suite
    and ready to be customized to suit your personal needs.

    Me enables you to maintain your dotfiles in a central 
    Git repository like Github to make them accessible from 
    multiple machines. 
    
    This repository can reside on a personal USB stick.
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

    HOMEBREW_CUSTOMIZING = '
    Homebrew prefix:

        ✔ home:     ~/Homebrew/
        ✔ library:  ~/Library/Homebrew/
        ✔ user:     (defined by yourself)
    '

    ME_CUSTOMIZING = '
    Home of Me:

        ✔ home:     ~/Me/
        ✔ library:  ~/Library/Me/
        ✔ user:     (defined by yourself)
    '

    LORD_CUSTOMIZING = '
    Home of Lord:

        ✔ home:     ~/Lord/
        ✔ library:  ~/Library/Lord/
        ✔ user:     (defined by yourself)
    '

    PREPARATIONS = '
    To set up a clean environment for bootstrapping
    very few preparations are required now. 

    I will backup "~/.bash_profile" and "~/.bashrc" for you.
    You will have to give your confirmation in each step.
    '

    BACKUPINFO = '
    A file "%s" is existing.
    I want to rename it to "%s".

    Enter stop to quit bootstrapping.
    '

end

def test
end

# test; exit

MeLordBootstrapper.new.main

