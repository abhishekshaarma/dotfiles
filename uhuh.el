
;;; init.el --- Personal Emacs Configuration
;;; Commentary:
;; This is a personal Emacs configuration file with custom settings for
;; editing, appearance, and C/C++ programming.

;;; Code:

;;=============================================================================
;; PACKAGE AND FILE LOADING SETTINGS
;;=============================================================================

;; Load newer bytecode files if they exist (for better performance)
(setq load-prefer-newer t)

;; Configure backup and auto-save file locations
;; Instead of cluttering working directories, store backups in ~/.emacs.d/
(setq save-place-file (concat user-emacs-directory "places")
      backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))

;;=============================================================================
;; MOUSE AND INTERACTION SETTINGS
;;=============================================================================

;; When using middle mouse to paste, paste at cursor location instead of click location
(setq mouse-yank-at-point t)

;; Use visual bell instead of audible beep
(setq visible-bell t)

;; Always add a newline at the end of files
(setq require-final-newline t)

;;=============================================================================
;; ENHANCED KEYBINDINGS
;; Replace default commands with more powerful alternatives
;;=============================================================================

;; Use interactive buffer list instead of basic buffer list
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Swap regular and regex search keybindings
;; Make regex search the default (more powerful for programming)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;; Copy character from line above cursor (useful for repetitive editing)
(global-set-key (kbd "M-m") 'copy-from-above-command)

;; Auto-indent after newline (vi-like behavior)
(global-set-key (kbd "RET") 'newline-and-indent)

;;=============================================================================
;; APPEARANCE AND UI SETTINGS
;;=============================================================================

;; Disable the Emacs startup screen
(setq inhibit-startup-screen t)
 
;; Configure UI elements
(menu-bar-mode 1)                    ; Keep menu bar (useful for beginners)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))               ; Remove tool bar (saves space)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))             ; Remove scroll bar (use keyboard navigation)

;; Show line and column numbers
(line-number-mode 1)                ; Show line number in mode line
(column-number-mode 1)              ; Show column number in mode line
(global-display-line-numbers-mode)  ; Show line numbers in left margin

;; Set text wrapping column to 79 characters (good for code readability)
(setq-default fill-column 79)

;; Highlight matching parentheses
(show-paren-mode 1)

;; Custom startup message
(defun startup-echo-area-message ()
  "Display custom startup message in echo area."
  "By your command...")

;;=============================================================================
;; INDENTATION AND EDITING BEHAVIOR
;;=============================================================================

;; Set tab width to 4 spaces
(setq tab-width 4)


;; Use spaces instead of tab characters for indentation
(setq-default indent-tabs-mode nil)

;; Remember cursor position in files
(setq-default save-place t)
;; Note: Uncomment the line below if you want to enable save-place-mode globally
;; (save-place-mode 1)

;; Set spell-checking dictionary to US English
(setenv "DICTIONARY" "en_US")

;;=============================================================================
;; C/C++ PROGRAMMING CONFIGURATION
;;=============================================================================

;; Define smart brace handling for C/C++ code
;; This function determines when to add newlines around opening braces
(defun c-brace-open (syntax pos)
  "Determine newline placement for opening braces based on context.
SYNTAX is the syntactic context, POS is the position of the brace."
  (save-excursion
    (let ((start (c-point 'bol))
          langelem)
      ;; Special handling for enum braces - add newlines before and after
      (if (and (eq syntax 'brace-list-open)
               (setq langelem (assq 'brace-list-open c-syntactic-context))
               (progn (goto-char (c-langelem-pos langelem))
                      (if (eq (char-after) ?{)
                          (c-safe (c-forward-sexp -1)))
                      (looking-at "\\<enum\\>[^_]")))
          '(before after)
        ;; For other cases, add newline after if brace is not at beginning of line
        (if (< (point) start)
            '(after))))))

;; Define smart brace handling for closing braces
(defun c-brace-close (syntax pos)
  "Determine newline placement for closing braces.
SYNTAX is the syntactic context, POS is the position of the brace."
  (save-excursion
    (goto-char pos)
    ;; Add newline before closing brace if it spans multiple lines
    (if (> (c-point 'bol)
           (progn (up-list -1) (point)))
        '(before))))


;; Ensure package system and use-package
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Define Doxygen comment highlighting patterns
(defconst doxygen-font-lock-doc-comments
  `(;; Highlight Doxygen tags like @param, \brief, etc.
    ("\\s-\\([\\@].*?\\)\\s-"
     1 font-lock-constant-face prepend nil)
    ;; Highlight parameter direction indicators
    ("\\[in\\]\\|\\[out\\]\\|\\[in,out\\]"
     0 font-lock-constant-face prepend nil)
    ;; Highlight function names in Doxygen comments
    ("\\<\\(?:[a-zA-Z_][a-zA-Z0-9_]*::\\)*[a-zA-Z_][a-zA-Z0-9_]*()"
     0 font-lock-constant-face prepend nil))
  "Font lock patterns for Doxygen documentation comments.")

;; Define how to apply Doxygen highlighting
(defconst doxygen-font-lock-keywords
  `((,(lambda (limit)
        ;; Apply highlighting to /** and /*! style comments
        (c-font-lock-doc-comments "/\\*[*!]<?" limit
          doxygen-font-lock-doc-comments)
        ;; Apply highlighting to /// and //! style comments
        (c-font-lock-doc-comments "//[/!]<?" limit
          doxygen-font-lock-doc-comments))))
  "Font lock keywords for Doxygen comments.")

;; Define custom C/C++ coding style named "aek"
(c-add-style "aek"
             '(;; Use Doxygen for documentation comments
               (c-doc-comment-style . doxygen)
               ;; Basic indentation: 4 spaces
               (c-basic-offset . 4)
               ;; No extra indentation for comment-only lines
               (c-comment-only-line-offset . 0)
               ;; Configure automatic brace insertion
               (c-hanging-braces-alist . ((substatement-open before after)
                                          (brace-list-open . c-brace-open)
                                          (brace-list-close . c-brace-close)
                                          (class-close before)))
               ;; Control automatic semicolon and comma insertion
               (c-hanging-semi&comma-criteria . (c-semi&comma-no-newlines-before-nonblanks
                                                 c-semi&comma-inside-parenlist))
               ;; Define indentation rules for various syntactic elements
               (c-offsets-alist . ((topmost-intro     . 0)   ; No indent for top-level
                                   (substatement      . +)   ; Indent substatements
                                   (substatement-open . 0)   ; No extra indent for opening braces
                                   (case-label        . +)   ; Indent case labels
                                   (access-label      . -)   ; Outdent access labels (public:, private:)
                                   (inclass           . +)   ; Indent class members
                                   (inline-open       . 0)   ; No extra indent for inline functions
                                   (brace-list-open   . 0)   ; No indent for brace list opening
                                   (brace-list-close  . 0))))) ; No indent for brace list closing

;; Apply "aek" style to C and C++ modes
(add-to-list 'c-default-style '(c-mode . "aek"))
(add-to-list 'c-default-style '(c++-mode . "aek"))

;; Set up C mode hook
(add-hook 'c-mode-common-hook 'c-mode-common-setup)

(defun c-mode-common-setup ()
  "Common setup for C-style programming modes."
  ;; Disable auto-newline and hungry-delete features
  ;; (These can be intrusive for some coding styles)
  (c-toggle-auto-hungry-state -1))

;;=============================================================================
;; THEME AND APPEARANCE CUSTOMIZATION
;;=============================================================================

;; Package and theme configuration
;; This section is automatically managed by Emacs' customize system
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruber-darker tango-dark))
 '(custom-safe-themes
   '("e13beeb34b932f309fb2c360a04a460821ca99fe58f69e65557d6c1b10ba18c7" default))
 '(package-selected-packages
   '(typescript-mode web-mode company lsp-ui lsp-mode rust-mode flycheck python gruber-darker-theme))
 '(warning-suppress-log-types '((package reinitialization) (auto-save)))
 '(warning-suppress-types '((auto-save))))

;; Font configuration
;; Popular programming fonts (uncomment your preferred choice):

;; Option 1: JetBrains Mono (excellent for programming, free ligatures)
;;(custom-set-faces
 ;;'(default ((t (:family "JetBrains Mono" :height 140)))))

;; Option 2: Fira Code (popular, great ligatures, free)
;; (custom-set-faces
;;  '(default ((t (:family "Fira Code" :height 140)))))

;; Option 3: Cascadia Code (Microsoft's programming font, ligatures)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Cascadia Code" :height 140)))))

;; Option 4: Source Code Pro (Adobe's clean programming font)
;; (custom-set-faces
;;  '(default ((t (:family "Source Code Pro" :height 140)))))

;; Option 5: Hack (designed specifically for programming)
;; (custom-set-faces
;;  '(default ((t (:family "Hack" :height 140)))))

;; Option 6: Inconsolata (narrow, space-efficient)
;; (custom-set-faces
;;  '(default ((t (:family "Inconsolata" :height 150)))))

;; Option 7: Monaco (macOS system font, very clean)
;; (custom-set-faces
;;  '(default ((t (:family "Monaco" :height 140)))))

;; Fallback to original if preferred fonts aren't available
;; (custom-set-faces
;;  '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 150 :width normal)))))


;; Enhanced file navigation (uncomment to enable)
;; (ido-mode 1)

;; Global save-place mode (uncomment to enable)
;; (save-place-mode 1)


;; Flycheck
;;(use-package flycheck
 ;; :init (global-flycheck-mode))
;; Ensure flycheck uses C++ checker
;;(add-hook 'c++-mode-hook
;;          (lambda ()
;;            (flycheck-select-checker 'c/c++-gcc) ;; or 'c/c++-clang
 ;;           (setq flycheck-gcc-language-standard "c++17")
  ;;          (flycheck-mode 1)))

;; --- Rust Setup ---
;; --- Minimal Rust Syntax Highlighting ---
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")


;; Add MELPA to your package archives if it's not already in your list
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install typescript-mode if not already installed
(unless (package-installed-p 'typescript-mode)
  (package-refresh-contents)
  (package-install 'typescript-mode))

;; Enable typescript-mode for .ts and .tsx files
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

(provide 'init)
;;; init.el ends here


