#lang scheme

#|  kd-tree-test.ss: Test suite for kd-tree.ss.
    Copyright (C) 2010 Will M. Farr <wmfarr@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
|#

(require schemeunit
         schemeunit/text-ui
         srfi/67
         "../kd-tree.ss")

(require/expose "../kd-tree.ss" (find-nth-sorted))

(provide tests)

(define (random-point-in-unit-cube n)
  (build-vector n (lambda (i) (random))))

(define (in-bounds? x low high)
  (for/and ((x (in-vector x))
            (l (in-vector low))
            (h (in-vector high)))
    (and (<= l x)
         (<= x h))))

(define (check-tree-invariant? ->coords tree)
  (or (empty-kd-tree? tree)
      (let ((left (cell-kd-tree-left tree))
            (right (cell-kd-tree-right tree)))
        (or (empty-kd-tree? left)
            (empty-kd-tree? right)
            (let ((left-objs (cell-kd-tree-objects left))
                  (right-objs (cell-kd-tree-objects right)))
              (let-values (((left-low left-high) (objects->bounds ->coords left-objs))
                           ((right-low right-high) (objects->bounds ->coords right-objs)))
                (and (for/and ((robj (in-list right-objs)))
                       (not (in-bounds? (->coords robj) left-low left-high)))
                     (for/and ((lobj (in-list left-objs)))
                       (not (in-bounds? (->coords lobj) right-low right-high)))
                     (check-tree-invariant? ->coords left)
                     (check-tree-invariant? ->coords right))))))))

(define tests
  (test-suite
   "denest.ss tests"
   (test-case
    "find-nth-sorted test"
    (for ((i (in-range 100)))
      (let* ((N 100)
             (l (build-list N (lambda (i) (random N))))
             (sorted-l (sort l (lambda (a b) (<? integer-compare a b))))
             (n (random N)))
        (check-equal? (list-ref sorted-l n)
                      (find-nth-sorted l n integer-compare)))))
   (test-case
    "real- and vector-compare"
    (for ((i (in-range 100)))
      (let ((c (vector-compare real-compare (random-point-in-unit-cube 2) (random-point-in-unit-cube 2))))
        (check-true (and (exact? c)
                         (<= -1 c 1))))))
   (test-case
    "2-D k-D tree invariant"
    (let ((pts (build-list 10000 (lambda (i) (random-point-in-unit-cube 2)))))
      (let ((tree (objects->kd-tree values pts)))
        (check-true (check-tree-invariant? values tree)))))))
             
    