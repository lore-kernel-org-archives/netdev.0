From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/9] drivers/net/s2io.c: Cleanups
Date: Wed, 26 Aug 2009 15:47:58 -0700
Message-ID: <1251326878.13026.52.camel@Joe-Laptop.home>
References: <cover.1251170438.git.joe@perches.com>
	 <20090826.153353.259743590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anil.murthy@neterion.com,
	sreenivasa.honnur@neterion.com, sivakumar.subramani@neterion.com,
	santosh.rastapur@neterion.com, ram.vepa@neterion.com,
	akpm@linux-foundation.org, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090826.153353.259743590.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> Since this is a pretty serious set of cleanups, I'd like to
> let the S2IO driver folks have some time to look at this and
> at least have a chance to ACK/NACK them.

No worries.  That's fine.  It's only cleanups.

I haven't heard from them though and they haven't
submitted or signed a patch for s2io in over a year.

Hey!  Neterion people!  Is anybody home?
