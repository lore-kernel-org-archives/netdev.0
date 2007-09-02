From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 11:18:24 +0100
Message-ID: <20070902111824.153bc036@the-village.bc.nu>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	<f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	<46D99FB7.6030505@garzik.org>
	<f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	<20070901205457.GK9260@stusta.de>
	<3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net>
	<20070902022253.GA18201@mail.netspace.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Dixon <jason@dixongroup.net>, bunk@kernel.org,
	mureninc@gmail.com, jeff@garzik.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	jirislaby@gmail.com
To: Jonathan Gray <jsg@goblin.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:33360 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755187AbXIBKKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 06:10:19 -0400
In-Reply-To: <20070902022253.GA18201@mail.netspace.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> co-operation. Together we advance our detective work and knowledge of
> the Macintosh platforms to the good of all Macintosh users dumped"
> 
> Alan Cox circa 1999.
> 
> http://lists.freedesktop.org/archives/xorg/2007-August/027419.html
> 
> "well I'd be quite happy to see X go GPL but I'm aware
> thats not the intention of the project ;)"
> Alan Cox circa 2007.
> 
> What changed? 

Nothing that I am aware of. You can't take Linux/Mac68K code back into
BSD either. BSD code is being used according to the BSD licence. You
could adopt a different licence if the way your code is being used
bothers you, thats.

Where I've reused BSD code I've aways tried to contribute it back to the
BSD people or share the knowledge (and the knowledge far more than the
code mattered both ways for Mac68K systems)

I suggest you read drivers/net/wan/syncppp.c, which is I think the only
BSD derived bit of code of mine left in the kernel - and its quite
specific what it says.

Ath5k isn't my code so I don't get to pick. Having the OpenBSD maintainer
make bogus remarks about that doesn't help anyone, especially when he's
wrong and doesn't appear to know about the subject in the first place.

Alan
