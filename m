From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: RE: [PATCH 0/9] drivers/net/s2io.c: Cleanups
Date: Mon, 31 Aug 2009 01:21:36 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705A1DF76@nekter>
References: <cover.1251170438.git.joe@perches.com> <20090826.153353.259743590.davem@davemloft.net> <1251326878.13026.52.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Anil Murthy" <Anil.Murthy@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	<akpm@linux-foundation.org>, <linux-next@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1251326878.13026.52.camel@Joe-Laptop.home>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe,
Patches look fine, I reviewed and tested these patches on latest
davem-net-next-2.6 sources.

Acked-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com> 

Regs
srini

-----Original Message-----
From: Joe Perches [mailto:joe@perches.com] 
Sent: Thursday, August 27, 2009 4:18 AM
To: David Miller
Cc: netdev@vger.kernel.org; Anil Murthy; Sreenivasa Honnur; Sivakumar
Subramani; Rastapur Santosh; Ramkrishna Vepa; akpm@linux-foundation.org;
linux-next@vger.kernel.org
Subject: Re: [PATCH 0/9] drivers/net/s2io.c: Cleanups

On Wed, 2009-08-26 at 15:33 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 24 Aug 2009 20:29:39 -0700
> > Just a few cleanups, compiled, untested.  No hardware.
> >   s2io.c: Use const for strings
> >   s2io.c: Shorten code line length by using intermediate pointers
> >   s2io.c: Use calculated size in kmallocs
> >   s2io.c: use kzalloc
> >   s2io.c: Make more conforming to normal kernel style
> >   s2io.c: convert printks to pr_<level>
> >   s2io.c: fix spelling explaination
> >   s2io.c: Standardize statistics accessors
> >   s2io.c: Convert skipped nic->config.tx_cfg[i]. to tx_cfg->
> 
> Since this is a pretty serious set of cleanups, I'd like to let the 
> S2IO driver folks have some time to look at this and at least have a 
> chance to ACK/NACK them.

No worries.  That's fine.  It's only cleanups.

I haven't heard from them though and they haven't submitted or signed a
patch for s2io in over a year.

Hey!  Neterion people!  Is anybody home?
