#lang scribble/manual

@(require (for-label scheme)
          (for-label "kd-tree.ss"))

@title{kD Trees}

This PLaneT package provides a library implementing
@link["http://en.wikipedia.org/wiki/Kd-tree"]{kD trees}.  In brief, a
kD tree partitions a set of objects in a geometric domain into a
binary tree by splitting the objects in half along successive
dimensions of the domain.  The @scheme[objects->kd-tree] procedure
chooses to split the domain along the dimension where the spread in
the objects is greatest.  The objects are split at the position in
this dimension occupied by the median object.  (Note that this
splitting procedure does not guarantee that there are equal objects on
either side of the split, since there may be many objects whose
coordinate in the splitting dimension equals the median.)

The library uses a fast median-finding algorithm, so the construction
of a tree with @scheme[n] points occurs in time of order @scheme[(* n
(log n))].  

The kD Tree PLaneT package is released under the
@link["http://www.gnu.org/licenses/gpl.html"]{GPL}; for more
information, see the COPYING file in the main library directory.

@section{Procedure Documentation}

@defmodule[(planet wmfarr/kd-tree:1:0/kd-tree)]

@defproc[(kd-tree? (obj any/c)) boolean?]{

A predicate for kD trees.

}

@deftogether[
(@defstruct[empty-kd-tree ()]
 @defstruct[cell-kd-tree
            ((objects (listof any/c))
             (left kd-tree?)
             (right kd-tree?))])]{

A kD tree is either empty, or a cell containing some objects and two
sub-trees for the objects whose coordinates are smaller and larger in
the splitting dimension, respectively.

}

@defproc[(objects->bounds (->coords (-> any/c (vectorof real?)))
                          (objects (listof any/c)))
         (values (vectorof real?) (vectorof real?))]{

Computes a pair of vectors, @scheme[low] and @scheme[high], such that,
for all @scheme[objects], @scheme[(<= low (->coords object)
high)].  (Note that the @scheme[->coords] procedure is used to extract
the coordinates of an object.)

}

@defproc[(objects->kd-tree (->coords (-> any/c (vectorof real?)))
                           (objects (listof any/c)))
         kd-tree?]{

Constructs a kD tree from the given @scheme[objects].  The
@scheme[->coords] procedure is used to extract the coordinates from an
object.  To construct a kD tree from @scheme[n] objects takes time of
order @scheme[(* n (log n))].

}

@subsection{A Note on @scheme[->coords] Procedures}

Both @scheme[objects->kd-tree] and @scheme[objects->bounds] use
procedures (@scheme[->coords]) to extract the coordinates of an
object.  This packages makes no attempt to minimize the number of
times such a procedure is called (i.e. by caching the output, or by
other means), so it is in the interest of the user of this package to
make the @scheme[->coords] procedure as fast as possible.