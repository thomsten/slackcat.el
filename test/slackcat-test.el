;;; slackcat-test.el --- Tests for slackcat.el

;; Copyright (C) 2013 Thomas Stenersen

;; Author: Thomas Stenersen <stenersen.thomas@gmail.com>

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for slackcat.el

;;; Code:

(require 'ert)
(require 'slackcat)

;; TODO: No tests :'(
(ert-deftest slackcat-remove-duplicates ()
  (should (equal (slackcat--remove-duplicates '("@bob" "@bob" "#devs")) '("@bob" "#devs"))))

(ert-deftest slackcat-test--dst-to-arg ()
  (should (equal "-c devs" (slackcat--dst-to-arg "sdfa wqr #devs bb"))))

(ert-deftest slackcat-test--dst-to-arg2 ()
  (should (equal "-c devs" (slackcat--dst-to-arg "<!-- TO: #devs -->"))))

(provide 'slackcat-test)

;;; slackcat-test.el ends here
