From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPsec AH use of ahash
Date: Sat, 19 Jan 2013 07:46:24 -0800
Message-ID: <1358610384.3464.1030.camel@edumazet-glaptop>
References: <1325444527.92017.1358591457919.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:49500 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab3ASPq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 10:46:28 -0500
In-Reply-To: <1325444527.92017.1358591457919.JavaMail.root@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-19 at 05:30 -0500, Tom St Denis wrote:

> As someone who maintained (and I mean that in all senses not just
> applied patches) OSS projects while working full time and still trying
> to have a life I get it.  That said I never turned away patches solely
> on "style" issues.  At the same time you should look at the size and
> scope of the patches I'm talking about.  It took me all of less than
> an hour to develop and less than a couple of hours to give it a run to
> see if it works correctly [talking about the CMAC patch].
> 
> This *should* be a no-brainer to apply.
> 

Again, if its a no-brainer, the patch should be perfect, so that our
brains can cope with the hard to review patches, and hard to debug
problems. A maintainer is not a machine doing mechanical work

Every time we have to ask you another round, its a lost of time for
everybody.

Really if you can not understand that, thats too bad.


> For those of us who do Kernel development during business hours it's
> hard to justify the work when the path to mainline is convoluted and
> landmined.  

Thousands of contributors just did it very well. 

You might read a bit Documentation/SubmittingPatches

vi +263 Documentation/SubmittingPatches

This is a bit outdated, as obviously Linus is not the guy most
contributors are dealing with.
