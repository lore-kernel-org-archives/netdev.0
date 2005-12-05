From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] move some code to net/ipx/af_ipx.c
Date: Mon, 5 Dec 2005 22:35:51 +0100
Message-ID: <20051205213550.GL9973@stusta.de>
References: <6.282480653@selenic.com> <7.282480653@selenic.com> <20051114015707.GB5735@stusta.de> <20051118052252.GG11494@stusta.de> <39e6f6c70511181224r20801b61j87c856c703ab2b4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, acme@conectiva.com.br,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932519AbVLEVfx@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline
In-Reply-To: <39e6f6c70511181224r20801b61j87c856c703ab2b4d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2005 at 06:24:10PM -0200, Arnaldo Carvalho de Melo wrote:
> On 11/18/05, Adrian Bunk <bunk@stusta.de> wrote:
> > On Mon, Nov 14, 2005 at 02:57:07AM +0100, Adrian Bunk wrote:
> > > On Fri, Nov 11, 2005 at 02:35:51AM -0600, Matt Mackall wrote:
> > > > trivial: drop unused 802.3 code if we compile without IPX
> > > >
> > > > (originally from http://wohnheim.fh-wedel.de/~joern/software/kernel/je/25/)
> 
> Thanks Adrian, from a quick glance looks OK, I'll review it later
> today to see if everything is fine wrt appletalk, tr, etc.

Any result from your review?

> - Arnaldo

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
