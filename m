From: "David S. Miller" <davem@redhat.com>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 20:46:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030602.204645.48505284.davem@redhat.com>
References: <3EDC1418.6080808@monmouth.com>
	<20030602.202233.39180859.davem@redhat.com>
	<3EDC18F2.6090505@monmouth.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jsd@monmouth.com
In-Reply-To: <3EDC18F2.6090505@monmouth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "John S. Denker" <jsd@monmouth.com>
   Date: Mon, 02 Jun 2003 23:41:38 -0400
   
   If we are taking the legal system as our
   model of openness, then open-source software
   has come to a sorry pass indeed.
   
It does have connections where a "user" wants to
do something with FOO but does not wish to do the
legwork necessary to be an expert in FOO.  They hire
an expert.

Or, in our case, they make an expert interested in the
thing they want to do :-)))
   
   It is also important to distinguish what's best
   for *you* and what's best for the project.
   Maybe *you* don't want to be responsible for
   doing all the documentation.

I'm not even going to attempt to document something that
moves as fast as the kernel.

I go to bookstores and I see many excellent attempts to document
kernel internals, but these books are frozen in time.  Specifically
they are frozen in the time of the moment the kernel they write for is
published.  As a consequence they are all obsolete the moment they are
published.

Some poor student reads these books, written against 2.4.8 or
whatever, then they go and try to contribute to 2.5.x and it
doesn't work except for certain kinds of drivers where we've
kept the APIs more or less the same.

But I don't care that people do this, just don't require that I do
it.

I think this extra fluidity we get from being able to change so fast
is a strength not a weakness.
