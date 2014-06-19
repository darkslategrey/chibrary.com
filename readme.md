Chibrary
========

TODO what it does

Install instructions
* Install Riak 1.4.8
* Install Redis 2.4.15
* Run `bundle install` to install the gems

Influences:
  Sandi Metz: Practical Object-Oriented Design in Ruby, Magic Tricks of Testing
  J.B. Rainsberger: Integration Tests Are A Scam
  Gary Bernhardt: Boundaries; Functional Core, Imperative Shell
  Eric Evans: Domain Driven Design

_Warning_: The ThreadWorker has a race condition, and only one copy can run at
a time. See its description for more information.


From the bottom up:

== Values

Values are immutable objects without identity or state, They are small,
reliable data structures. These should all prepend the DeepFreeze module.
If any wanted to use attr_accessor, it would not be a Value.

A few are persisted. They are never updated, though they may be discarded and
replaced. Arguably this makes them an Entity, but they have no code and I
don't want them built in a mutable way.

=== CallNumber

The unique ID of a Message, and thus a Thread (because it's the root message
of the thread). It is 8 characters long and composed solely of a-z, A-Z, 0-9.

[Blog post on the design](http://push.cx/2014/distributed-id-generation-and-bit-packing-chibrary)

=== Email

The raw data for an email as scraped or received, with Headers extracted from
it.

=== Headers

Thin wrapper around RMail::Parser and its Header objects to parse and extract
headers. Note that this is plural, one object acccesses all headers, and it
does not recognize when being asked for a date/subject/message-id header to
return a specialized class. (Maybe this should change.)

=== MessageId

The hopefully-unique ID of an Email generated by the original sender. Can be
maliciously duplicated. Often missing in scraped archives.

=== MonthCount

Count of Threads and Messages for one month of a List.

=== Subject

The subject line of an Email. Can normalize, to strip Re/Fwd gunk, which is
often seen as n_subject.

=== SumCount

The sum of many MonthCounts.

=== Summary

A stripped-down version of a Message, used to store smaller objects when
working with Threads.

=== Sym

Slug, year, and month. Unique identifier for a List's month page. Previously
Threads were sorted grouped by Sym.

=== Sy

Slug and year. I have no idea why this object ever existed, but I remember
feeling it was important to have.

=== ThreadLink

A Sym, CallNumber, and Subject are used to make links to next/previous
Threads on the Thread Route.

=== TimeSort

An ordered list of ThreadLinks for a Sym.

...there should probably be a Slug value, but isn't.

== Entities
== Repos
== Services
== Routes

Tests
  duplication

  contract
  collaboration
  integration
