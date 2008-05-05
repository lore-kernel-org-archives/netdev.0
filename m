From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Sun, 04 May 2008 22:59:26 -0700 (PDT)
Message-ID: <20080504.225926.160484693.davem@davemloft.net>
References: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
	<20080429.152014.00555445.davem@davemloft.net>
	<Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: miika@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbYEEF70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 01:59:26 -0400
In-Reply-To: <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miika Komu <miika@iki.fi>
Date: Mon, 5 May 2008 08:55:49 +0300 (EEST)

> On Tue, 29 Apr 2008, David Miller wrote:
> > From: Miika Komu <miika@iki.fi>
> > Date: Wed, 30 Apr 2008 00:07:56 +0300 (EEST)
> >
> > This is not how we do things.
> >
> > When the HIP implementation is submitted for inclusion, the module
> > exports can be added, not before.
> 
> I am sorry but this somewhat conflicts with your earlier statement:
> 
> http://www.linux.sgi.com/archives/netdev/2005-03/msg01214.html
> 
> We took an huge effort in our project to move the HIP implementation to 
> the userland. I feel puzzled on how to continue. Please give some advice?

I didn't say I would accept a HIP implementation into the
kernel, I'm speaking in general terms about exporting symbols
for new features that aren't in the tree yet.

Does that make you feel better?
