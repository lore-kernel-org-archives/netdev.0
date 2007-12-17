From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 20:24:43 -0800 (PST)
Message-ID: <20071216.202443.251372179.davem@davemloft.net>
References: <20071216142915.c120d25c.akpm@linux-foundation.org>
	<20071216.152606.35263254.davem@davemloft.net>
	<4765D4F0.5040202@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, herbert@gondor.apana.org.au, rjw@sisk.pl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751186AbXLQEYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 23:24:46 -0500
In-Reply-To: <4765D4F0.5040202@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 16 Dec 2007 20:46:24 -0500

> David Miller wrote:
> > [Patch 1/7] [SUBSYSTEM]: Foo bar baz...
> 
> The most popular tool is git-am, which I and many others use.
> 
> git-am will snip "[SUBSYSTEM]" in the example that you give.

It should only snip the first "[Patch X/Y] " part, or the manual is
buggy :-)
