From: Bill Fink <billfink@mindspring.com>
Subject: Re: Reporting bugs and bisection
Date: Tue, 15 Apr 2008 01:25:33 -0400
Message-ID: <20080415012533.832db7ed.billfink@mindspring.com>
References: <20080413232441.e216a02c.akpm@linux-foundation.org>
	<20080414072328.GW9785@ZenIV.linux.org.uk>
	<20080414010412.c42dc560.akpm@linux-foundation.org>
	<20080414.013058.149905948.davem@davemloft.net>
	<878wzgwyyw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	viro@ZenIV.linux.org.uk, w@1wt.eu, david@lang.hm,
	sclark46@earthlink.net, johnpol@2ka.mipt.ru, rjw@sisk.pl,
	tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <git-owner@vger.kernel.org>
In-Reply-To: <878wzgwyyw.fsf@basil.nowhere.org>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Apr 2008, Andi Kleen wrote:

> David Miller <davem@davemloft.net> writes:
> >
> > It's still largely free form, loose, and flexible. 
> 
> I think Al's point was that we need far more "free form, loose and
> flexible" work for reviewing code. As in people going over trees and
> just checking it for anything suspicious and going over existing code
> and checking it for anything suspicious and going also over mailing
> list patch posts. And also maintainers who appreciate such review.
> 
> And checking it for anything suspicious does not mean running
> only checkpatch.pl or even just sparse, but actually reading it
> and trying to make sense of it.

If you really want to get more such review, then it would be very
useful when someone asks about some obtuse portion of kernel code
or makes a suggested improvement, that the reviewer then not be
flamed as being dense for not understanding the code or some kernel
coding concept.  It would be much better to treat it as an oppurtunity
to educate rather than belittle, thus eventually enlarging the base
of people who can assist with various aspects of kernel development.
For what's supposed to be an open, engaging community, and which
generally is, there sometimes seems to be some level of dismissal
of newcomers (not sure it's intended that way but nevertheless it
can tend to discourage newcomers from getting more involved).

						-Bill
