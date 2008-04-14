From: David Miller <davem@davemloft.net>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 01:30:58 -0700 (PDT)
Message-ID: <20080414.013058.149905948.davem@davemloft.net>
References: <20080413232441.e216a02c.akpm@linux-foundation.org>
	<20080414072328.GW9785@ZenIV.linux.org.uk>
	<20080414010412.c42dc560.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, w@1wt.eu, david@lang.hm,
	sclark46@earthlink.net, johnpol@2ka.mipt.ru, rjw@sisk.pl,
	tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755466AbYDNIbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 04:31:01 -0400
In-Reply-To: <20080414010412.c42dc560.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 14 Apr 2008 01:04:12 -0700

> That all sounds good and I expect few would disagree.  But if it is to
> happen, it clearly won't happen by itself, automatically.  We will need to
> force it upon ourselves and the means by which we will do that is process
> changes.  The thing which is being disparaged as "bureaucracy".
> 
> The steps to be taken are:
> 
> a) agree that we have a problem
 ...
> I have thus far failed to get us past step a).

A lot of people, myself included, subconsciously don't want to
get past step a) because the resulting "bureaucracy" or whatever
you want to call it is perceived to undercut the very thing
that makes the Linux kernel fun to work on.

It's still largely free form, loose, and flexible.  And that's
a notable accomplishment considering how much things have changed.
That feeling is why I got involved in the first place, and I know
it's what gets other new people in and addicted too.

Nobody is "forced" to do anything, and I notice you used the
word "force" in d) :-)

And I realize this relaxed attitude goes hand in hand with reduced
quality and occaisionally more bugs.  In many ways, I'm happy with
that tradeoff at least wrt. how that works out for the subsystems
I'm responsible for.

We can ask more subsystem tree maintainers to run their trees more
strictly, review patches more closely, etc.  But, be honest, good luck
getting that from the guys who do subsystem maintainence in their
spare time on the weekends.  The remaining cases should know better,
or simply don't care.
