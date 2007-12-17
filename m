From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 20:36:41 -0800 (PST)
Message-ID: <20071216.203641.75015660.davem@davemloft.net>
References: <20071216.152606.35263254.davem@davemloft.net>
	<4765D4F0.5040202@garzik.org>
	<20071216185548.bc9f1918.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, herbert@gondor.apana.org.au, rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751785AbXLQEgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 23:36:42 -0500
In-Reply-To: <20071216185548.bc9f1918.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 16 Dec 2007 18:55:48 -0800

> Kinda funny.  I (and I bet lots of others) spend a lot of time
> fixing, cleaning up and totally rewriting patch titles.

It's probably the majority of the typing I perform to apply a patch
except for the folks who format things the way that works best for
me.

I realize that I can't get every patch submitter to conform to what I
want, but at least I try to nudge the people who submit the most stuff
to me.

And it's just as much to "help me out" as it is that I want the
changelogs header lines to look consistent.  I'm going to enforce that
consistency anyways. :-)

But if people submit patches in a way that makes life difficult for
the subsystem maintainer, and keeps doing so after being asked to
adjust their submissions a little bit, well... some patches might get
mysteriously ignored.

When you're submitting a lot of patches you're chewing up a LOT of
someone's bandwidth.  I often spend at least 45 minutes a day on
network namespace patches, as one specific example.  That's a large
investment of time to give someone.

In return it's asking very little to "make your subject lines look
like this, it helps me a lot, kthx".

