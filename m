From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 29 Oct 2010 11:13:52 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010291057420.25426@eddie.linux-mips.org>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com> <1288316896.1836.41.camel@Joe-Laptop> <20101029094050.GA1835290@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:49365 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab0J2KNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 06:13:53 -0400
Received: from localhost.localdomain ([127.0.0.1]:54585 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491031Ab0J2KNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 12:13:52 +0200
In-Reply-To: <20101029094050.GA1835290@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Oct 2010, David Lamparter wrote:

> > > The initial target is things like ISA/EISA/MCA drivers, and with
> > > that alone, we can get close to 90 files out of drivers/net.
> > > Plus, by having a semi-defined description for legacy as being
> > > "drivers more than 10 years old" we'll always have a destination
> > > for drivers as they fall out of maintainership and use.
> > 
> > I think legacy is "old and not sold or used much anymore".
> > 
> > I believe you're not moving 3c59x as that's relatively
> > still popular even though it's nearly 15 years old.
> > 
> > Or maybe that was just an oversight...
> 
> The 3c59x driver also drives a few not-that-old 100MBit cards like
> "3Com Corporation 3c905B 100BaseTX [Cyclone] [10b7:9055] (rev 64)"
> and these are quite common still :)

 What's the difference? -- that's a change of the name only you should be 
proud of! ;)

 I have seen plenty of these Vortex/Boomerang/Cyclone cards in various 
configurations and still have a couple myself, but I fail to recall any 
that would be less than 8 years old, which is about the age of my newest 
FDDI stuff (updated by the manufacturer to universal PCI and HP-branded 
because of the DEC/Compaq acquisition) which has been declared "obviously 
obsolete", so why shouldn't this equipment be either? ;)

  Maciej
