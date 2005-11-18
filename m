From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [2.6 patch] move some code to net/ipx/af_ipx.c
Date: Fri, 18 Nov 2005 18:24:10 -0200
Message-ID: <39e6f6c70511181224r20801b61j87c856c703ab2b4d@mail.gmail.com>
References: <6.282480653@selenic.com> <7.282480653@selenic.com>
	 <20051114015707.GB5735@stusta.de> <20051118052252.GG11494@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Matt Mackall <mpm@selenic.com>, acme@conectiva.com.br,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161175AbVKRUYM@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051118052252.GG11494@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/18/05, Adrian Bunk <bunk@stusta.de> wrote:
> On Mon, Nov 14, 2005 at 02:57:07AM +0100, Adrian Bunk wrote:
> > On Fri, Nov 11, 2005 at 02:35:51AM -0600, Matt Mackall wrote:
> > > trivial: drop unused 802.3 code if we compile without IPX
> > >
> > > (originally from http://wohnheim.fh-wedel.de/~joern/software/kernel/je/25/)

Thanks Adrian, from a quick glance looks OK, I'll review it later
today to see if everything is fine wrt appletalk, tr, etc.

- Arnaldo
