(in-package :shipshape)

;; before shipped path is local to system
;; after shipped (and if has manifest) is local to media/system-name/

(defun local-path (path system)
  ;; local-media-path is inlined as then the compiler will optimize away
  ;; the redudent conditionals
  (let ((manifest (when *shipped* (find-manifest system))))
    (if manifest
        (progn
          (format t "~%shipped ~a, manifest ~a" *shipped* manifest)
          (local-media-path manifest path))
        (asdf:system-relative-pathname system path))))


(defun local-media-path (manifest &optional (path ""))
  (with-slots (system system-media-path) manifest
    (reduce #'(lambda (x y) (merge-pathnames y x))
            (list system-media-path
                  (format nil "~a/" system)
                  path)
            :initial-value
            (if *shipped*
                (directory-namestring (first sb-ext:*posix-argv*))
                (asdf:system-relative-pathname system (build-path manifest))))))


(defun local-c-library-path (manifest &optional (path ""))
  (with-slots (system c-library-path) manifest
    (reduce #'(lambda (x y) (merge-pathnames y x))
            (list c-library-path
                  path)
            :initial-value
            (if *shipped*
                (directory-namestring (first sb-ext:*posix-argv*))
                (asdf:system-relative-pathname system (build-path manifest))))))


(defun ensure-no-directory (pathname)
  (when (cl-fad:directory-exists-p pathname)
    (cl-fad:delete-directory-and-files pathname)))


;; local-path
;; - relative to system
;; - relative to system media path

;; local-media-path
;; - in build-folder/system-media-path
;; - in exe-path/system-media-path
