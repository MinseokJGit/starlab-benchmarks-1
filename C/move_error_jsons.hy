;;;; A throwaway program for moving json files describing either memory or resource leaks.
;;;; To run this script: `pip install hy` then enter `hy move_error_jsons.hy`
;;;; NOTE Run this script under /startlab-benchmarks/C/


(import os)
(import os.path)
(import [shutil [move]])


(defn get-prefix [string_]
  (get (.split string_ "_") 0))


;;; moving project repos to src/

(defn make-src-subdirectories []
  "make a subdirectory called src_/ under all benchmark folders."
  (setv prefixes (get-prefixes))
  (for [prefix prefixes]
    (when (in ".DS" prefix)
      (continue))
    (setv target-dir (+ prefix "/src_"))
    (when (not (os.path.isdir target-dir))
      (os.mkdir target-dir))))


(defn move-all-repo-files []
  "for all prefixes, move the repo files to src_/"
  (setv prefixes (get-prefixes))
  (setv current-dir (os.getcwd))
  (for [prefix prefixes]
    (when (in ".DS" prefix)
      (continue))
    (move (os.path.join current-dir prefix) (+ current-dir prefix "/src_"))))


(defn rename-src-underbar []
  "rename src_ to src"
  (setv prefixes (get-prefixes))
  (for [prefix prefixes]
    (when (in ".DS" prefix)
      (continue))
    (move (+ prefix "/src_") (+ prefix "/src"))))


;;; integrating resource-leak and memory-leaks into one.

(defn partition-memory-leaks []
  "partition the memory-leak jsons by repositories."
  (setv name-pool (os.listdir "error_reports/memory-leak"))
  (setv prefix-pool (set (map (fn [name_] (get-prefix name_)) name-pool)))
  (setv acc {})
  (for [prefix prefix-pool]
    (setv small-acc [])
    (for [name_ name-pool]
      (when (= (get-prefix name_) prefix)
        (.append small-acc name_)))
    (.sort small-acc)
    (setv (get acc prefix) small-acc))
  acc)


(defn partition-resource-leaks []
  "partition the resource-leak jsons by repositories."
  (setv name-pool (os.listdir "error_reports/resource-leak"))
  (setv prefix-pool (set (map (fn [name_] (get-prefix name_)) name-pool)))
  (setv acc {})
  (for [prefix prefix-pool]
    (setv small-acc [])
    (for [name_ name-pool]
      (when (= (get-prefix name_) prefix)
        (.append small-acc name_)))
    (.sort small-acc)
    (setv (get acc prefix) small-acc))
  acc)


(defn get-prefixes []
  (setv ml-name-pool (os.listdir "error_reports/memory-leak"))
  (setv rl-name-pool (os.listdir "error_reports/resource-leak"))
  (setv all-name-pool (+ ml-name-pool rl-name-pool))
  (set (map (fn [name_] (get-prefix name_)) all-name-pool)))


(defn integrate-for-prefix [prefix memory-leaks resource-leaks]
  "integrate the two kinds of leak jsons by renaming them at the same time, given a prefix."
  (setv cnt 1)
  (setv rl-renamed [])
  (for [rl-name memory-leaks]
    (.append rl-renamed (, (+ "memory-leak/" rl-name) (+ prefix "/bugs/" "bug_" (str cnt))))
    (setv cnt (inc cnt)))
  (setv ml-renamed [])
  (for [ml-name resource-leaks]
    (.append ml-renamed (, (+ "resource-leak/" ml-name) (+ prefix "/bugs/" "bug_" (str cnt))))
    (setv cnt (inc cnt)))
  (+ rl-renamed ml-renamed))


(defn integrate-for-all-prefix []
  "call integrate-for-prefix for all prefixes."
  (setv prefixes (get-prefixes))
  (setv mls (partition-memory-leaks))
  (setv rls (partition-resource-leaks))
  (setv acc {})
  (for [prefix prefixes]
    (try
      (setv ml-for-prefix (get mls prefix))
      (except []
        (setv ml-for-prefix [])))
    (try
       (setv rl-for-prefix (get rls prefix))
       (except []
         (setv rl-for-prefix [])))
    (setv (get acc prefix) (integrate-for-prefix prefix ml-for-prefix rl-for-prefix)))
  acc)


;;; make subdirectories for the git mv commands.

(defn make-bugs-subdirectories []
  "create the bugs/ subdirectories for each prefix, if there isn't one."
  (setv prefixes (get-prefixes))
  (for [prefix prefixes]
    (when (in ".DS" prefix)
      (continue))
    (setv target-dir (+ prefix "/bugs"))
    (when (not (os.path.isdir target-dir))
      (os.mkdir target-dir))))


(defn make-git-mv-commands-for-prefix [tuple-list]
  "create the git mv commands, given a prefix."
  (setv acc [])
  (for [(, original new) tuple-list]
    (.append acc (+ "git mv " original " " new)))
  acc)


(defn make-git-mv-commands []
  (setv integrated-dict (integrate-for-all-prefix))
  (setv prefixes (get-prefixes))
  (setv acc [])
  (for [prefix prefixes]
    (setv integrated-list (get integrated-dict prefix))
    (.append acc (make-git-mv-commands-for-prefix integrated-list)))
  acc)


(defn run-git-mv-commands [commands]
  (for [command commands]
    (os.system command)))


(defn run-all-git-mv-commands []
  (setv command-list-list (make-git-mv-commands))
  (for [command-list command-list-list]
    (run-git-mv-commands command-list)))


;; main function

(defmain []
  (print "starting...")
  (print "scanning directories...")
  (print "making relevant subdirectories...")
  (make-src-subdirectories)
  (make-bugs-subdirectories)
  (print "moving all repo files to src/...")
  (move-all-repo-files)
  (return)
  (rename-src-underbar)
  (print "running git mv commands...")
  (run-all-git-mv-commands)
  (print "done"))