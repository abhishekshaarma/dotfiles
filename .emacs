;;; -*- lexical-binding: t; -*-

;; Ensure package system and use-package
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; UI Tweaks
(tool-bar-mode -1)
(menu-bar-mode 1)
(scroll-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode t)
(setq display-line-number-type 'relative)

;; Theme
(use-package gruber-darker-theme
  :init (load-theme 'gruber-darker t))

;; Flycheck
(use-package flycheck
  :init (global-flycheck-mode))

