# #! /usr/bin/env ruby
# vim: tabstop=4 shiftwidth=4 expandtab fdm=syntax

require 'time'
require 'readline'
require 'fileutils'

class MeLordBootstrapper

    def main
        begin
            init
            intro
            homes
            backup
            reconfigure
            homebrew
            ansible
            lord if @install_lord
            me if @install_me
            report
        rescue Interrupt
            rollback
        rescue Exception
            rollback
            raise
        end
    end

    def init
        @git_repo = 'https://github.com/Homebrew/homebrew.git'
        @lord_repo = 'https://github.com/elmar-hinz/OSX.Lord.git'
        @me_repo = 'https://github.com/elmar-hinz/OSX.Me.git'
        @backup = {}
        @installed = [] 
        @timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
        @home = ENV.fetch('HOME')
        @bashrc = '.bashrc'
        @bash_profile = '.bash_profile'
        @bashrc_fully = @home + '/' + @bashrc
        @bash_profile_fully = @home + '/' + @bash_profile
        @home_library = @home + '/Library'
    end

    def intro
        Interface.h1 'The Zen Path of Bootstrapping'
        Interface.pre Content::INTRO_TEXT
        Interface.confirm? "Go on!"
        Interface.h2 'Me'
        Interface.pre Content::ABOUT_ME
        @install_me = Interface.yes_no? 'Do you want to install *Me*?'
        Interface.h2 'Lord'
        Interface.pre Content::ABOUT_LORD
        @install_lord = Interface.yes_no? 'Do you want to install Lord?'
    end

    def homes
        Interface.h2 'Customization'
        @homebrew_home = home? 'Homebrew Prefix', Content::HOMEBREW_HOME, '/Homebrew'
        @homebrew_temp = @homebrew_home + '/Temp'
        @homebrew_cache = @home + '/Library/Caches/Homebrew'
        if @install_lord == :yes then
            @lord_home = home? 'Home of Lord', Content::LORD_HOME, '/Lord' 
        end
        if @install_me == :yes then
            @me_home = home? 'Home of Me', Content::ME_HOME, '/Me' 
        end
    end

    def home? title, intro, directory
        Interface.h3 title
        Interface.pre intro
        taste = Interface.query? 'Select your installation type!', [:home, :library, :user, :volume], :home 
        if taste == :home then
            home = @home  + directory
        elsif taste == :library then
            home = @home_library + directory
        elsif taste == :user then
            text = 'Please set your path (without the trailing directory "%s")'
            path =  path?(sprintf(text, directory), @home)
            home = path + directory
        elsif taste == :volume then
            text = 'Please set your path (without the trailing directory "%s")'
            path =  path?(sprintf(text, directory), '/Volumes/')
            home = path + directory
        end
        Interface.pre ' => Home: ' + home.green
        puts
        Interface.confirm?
        home
    end

    def path? question, prefill
        Interface.p question
        Interface.p '(Use Tab for autocompletion)'.yellow
        Readline.pre_input_hook = proc {
            Readline.insert_text prefill
            Readline.redisplay
        }
        line = Readline.readline(' > ').gsub(/\/$/, '') 
        Readline.pre_input_hook = nil
        line
    end

    def backup
        Interface.h2 'Preparations'
        Interface.pre Content::BACKUP
        list = [@bashrc_fully, @bash_profile_fully, @homebrew_home]
        list << @lord_home if @install_lord
        list << @me_home if @install_me
        list.each do |filename|
            basename = File.basename filename
            dirname = File.dirname filename
            backupbase = basename + '.backup.' + @timestamp
            backupfile = dirname + '/' + backupbase 
            if File.exist? filename or File.symlink? filename
                begin
                    File.rename filename, backupfile
                    Interface.success 'Moving ' + filename,  "to " + backupfile 
                    @backup[backupfile] = filename
                rescue Exception
                    Interface.fatal 'Moving ' + filename,  "to " + backupfile 
                    raise
                end
            end
        end
        Interface.success 'Backups done'
        Interface.confirm?
    end

    def reconfigure
        @installed << @bashrc_fully << @bash_profile_fully
        Interface.h2 'Installation'
        Interface.p 'Reconfiguring dotfiles'
        begin
            Dotfiles.prependPATH @homebrew_home + '/sbin', @bashrc_fully 
            Dotfiles.prependPATH @homebrew_home + '/bin', @bashrc_fully 
            Dotfiles.prependPATH @lord_home + '/bin', @bashrc_fully if @install_lord 
            Dotfiles.prependPATH @me_home + '/bin', @bashrc_fully if @install_me
            Dotfiles.export 'HOMEBREW_PREFIX', @homebrew_home, @bashrc_fully
            Dotfiles.export 'HOMEBREW_TEMP', @homebrew_temp, @bashrc_fully
            Dotfiles.export 'HOMEBREW_CACHE', @homebrew_cache, @bashrc_fully
            Dir.chdir(@home) do
                File.symlink @bashrc, @bash_profile
            end
        rescue Exception
            Interface.fatal 'Could not reconfigure dotiles'
            raise
        end
        Interface.success 'Reconfigured dotfiles'
        Interface.p 'Sourcing dotfiles'
        begin
            ENV.replace(eval(`bash -c 'source #{@bashrc_fully} && ruby -e "p ENV"'`))
        rescue Exception
            Interface.fatal 'Could not resource dotfiles'
            raise
        end
        Interface.success 'Sourced dotfiles'
    end

    def homebrew
        @installed << ENV['HOMEBREW_PREFIX']
        cmd = "git clone #{@git_repo}  #{ENV['HOMEBREW_PREFIX']}"
        Interface.p 'Cloning Homebrew'
        begin
            raise unless system(cmd)
        rescue Exception 
            Interface.fatal 'Could not clone Homebrew', cmd
            raise
        end
        Interface.success 'Cloned Homebrew', 'into ' + ENV['HOMEBREW_PREFIX']
        begin
            Dir.mkdir(ENV['HOMEBREW_TEMP'])
        rescue Exception 
            Interface.fatal 'Could not create: ', ENV['HOMEBREW_TEMP']
            raise
        end
    end
    
    def ansible
        cmd = 'brew install ansible'
        Interface.p 'Brewing Ansible'
        begin
            raise unless system(cmd)
        rescue Exception 
            Interface.fatal 'Could not brew Ansible', cmd
            raise
        end
        Interface.success 'Brewed Ansible'
    end

    def lord
        @installed << @lord_home
        cmd = "git clone #{@lord_repo}  #{@lord_home}"
        Interface.p 'Cloning Lord'
        begin
            raise unless system(cmd)
        rescue Exception 
            Interface.fatal 'Could not clone Lord', cmd
            raise
        end
        Interface.success 'Cloned Lord', 'into ' + @lord_home 
    end

    def me
        @installed << @me_home
        cmd = "git clone #{@me_repo}  #{@me_home}"
        Interface.p 'Cloning Me'
        begin
            raise unless system(cmd)
        rescue Exception 
            Interface.fatal 'Could not clone Me', cmd
            raise
        end
        Interface.success 'Cloned Me', 'into ' + @me_home 
    end

    def report
        Interface.p 'DONE'
        Interface.p 'Now is your last chance to interrup and restore from backup. ' + '[CTRL-C]'.blue
        Interface.confirm? 'To accept the installation '
    end

    def rollback
            Interface.h2 'Interrupt', false
            Interface.p 'Rolling back'
            @installed.each do |target|
                begin
                    if File.exist? target or File.symlink? target then
                        FileUtils.rm_rf target
                    end
                rescue Exception
                    Interface.fatal 'The rollback did fail: delete ' + target
                    raise 
                end
            end
            @backup.each do |backup, target|
                begin
                    File.rename backup, target
                rescue Exception
                    Interface.fatal 'The rollback did fail: rename ' + backup
                    raise 
                end
            end
            Interface.success 'Original state of system'
    end

end

module Dotfiles

    def self.prependPATH prependix, dotfile
        appendix = sprintf('export PATH="%s:$PATH"' + "\n", prependix)
        File.open(dotfile, 'a') { |f| f.write(appendix) }
    end

    def self.export key, value, dotfile
        appendix = sprintf('export %s="%s"' + "\n", key, value)
        File.open(dotfile, 'a') { |f| f.write(appendix) }
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
        prefixes[:success] = "    \33[1;32m✔ "
        prefixes[:warn]    = "    \33[1;33m➜ "
        prefixes[:error]   = "    \33[1;31m✖ "
        puts prefixes[status] << title << "\033[0m" 
        puts "        " << text if text
    end

    def self.pre text
        puts text
    end

    def self.p text
        puts '    ' + text.strip.gsub("\n", ' ')
    end

    def self.h1 title, clear = true
        self.h title, '+', clear
    end

    def self.h2 title, clear = true
        self.h title, '-', clear
    end

    def self.h3 title, clear = true
        self.h title, '.', clear
    end

    def self.h title, char, clear = true
        width = 80
        system "clear" if clear
        puts
        puts
        puts
        puts char * width
        puts (' ' * ((width - title.length)/2)) << title.red
        puts char * width
        puts
    end

    def self.confirm? question = '' 
        puts
        if question.empty? then
            puts ' ➜  Hit ' + '[ENTER]'.green
        else     
            puts "    " << question << " ➜  Hit " + "[ENTER]".green
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
                option = option.to_s.capitalize.green
            end
            option.to_s
        }
        puts
        puts " ➜  " + question << ' (' << displayed_options.join('|') << ')'
        result = nil
        until result
            answer = Readline.readline '  > '
            answer = answer.empty? ? default.to_s : answer
            result = options.select { |option| 
                option.to_s[0,1].capitalize == answer[0,1].capitalize
            }.first
            puts 'Please answer with one of: ' << 
                options.map{|o|o.to_s[0,1]}.join(', ') unless result
                
        end
        Interface.pre ' => ' + result.to_s.green
        puts
        result
    end

end

class String
    def red 
        "\033[1;31m" + self + "\033[0m"
    end

    def green
        "\033[1;32m" + self  + "\033[0m"
    end

    def yellow
        "\033[1;33m" +  self + "\033[0m"
    end

    def blue
        "\033[1;34m" + self + "\033[0m"
    end

end

module Content

    INTRO_TEXT = '
    I will install this basic software:

        ✔ Homebrew
        ✔ Ansible

    You have the option to install two additional admin tools:

        ✔ Me (stable)
        ✔ Lord (early)
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

    HOMEBREW_HOME = '
        ✔ home:     ~/Homebrew/
        ✔ library:  ~/Library/Homebrew/
        ✔ user:     (defined by yourself)
        ✔ volume:   (volume, i.e. USB stick) 
    '

    ME_HOME = '
        ✔ home:     ~/Me/
        ✔ library:  ~/Library/Me/
        ✔ user:     (defined by yourself)
        ✔ volume:   (volume, i.e. USB stick) 
    '

    LORD_HOME = '
        ✔ home:     ~/Lord/
        ✔ library:  ~/Library/Lord/
        ✔ user:     (defined by yourself)
        ✔ volume:   (volume, i.e. USB stick) 
    '

    BACKUP = '
    I backup files and directories if they already exist.

    Interrupt ' + '[CTRL-C]'.blue + ' to restore from backup at any time of this script.
    '

end

def test
end

MeLordBootstrapper.new.main

