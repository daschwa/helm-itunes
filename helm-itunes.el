;;;  helm-itunes.el Play local Spotify Tracks
;; Copyright 2014 Adam Schwartz
;;
;; Author: Adam Schwartz <adam@adamschwartz.io>
;; URL: https://github.com/daschwa/helm-itunes
;; Created: 2014-06-02 19:32:16
;; Version: 0.0.1

;;; Commentary:
;;
;; A search & play interface for iTunes.
;;
;; Currently only supports OSX.
;;

;;; Code:

;; (defvar track-uri "spotify:local:Beastie+Boys:Ill Communication:Sure+Shot:123")
;; (shell-command (format "osascript -e 'tell application %S to play track %S'" "Spotify" track-uri))

;; Either an artist, album, or song name to search for.
(defvar search-pattern "Sure Shot")

;; AppleScript that searches iTunes for songs.
(defvar search-script
  (format "-- toggle a variable if iTunes was running before this script was run.
    -- if application \"iTunes\" is running then
    --	set irun to true
    -- else
    --	set irun to false
    -- end if
    
    set pattern to %S
    
    set matches to {}
    tell application \"iTunes\"
	repeat with t in (file tracks whose artist contains pattern ¬
		or album contains pattern or name contains pattern)
		set matches to matches & ¬
			{{artist of t as string, album of t as string, ¬
				(name of t as string) & \"pattern-match-end\"}}
	end repeat
	
    end tell
    
    -- If you never had iTunes open, then quit after performing the search, 
    -- otherwise leave it open.
    
    -- if not irun then
    -- 	tell application \"iTunes\" to quit
    -- end if
    
    -- Return the list of songs that matched the search
    return matches" search-pattern))


;; Return a list of matches from the results of running the AppleScript.
;; Take the string of matches separated by commas and "pattern-match-end".
;; Split the string into a list of songs, then split each song into
;; a list of artist, album, and name.
;; Finally, concatenate the list items into a single string.

(mapc (lambda (song-list)
        (split-string song-list "\\,\s")) (split-string 
                                           (shell-command-to-string 
                                            (format "osascript -e %S" search-script)) 
                                           "pattern-match-end,\s\\|pattern-match-end"))