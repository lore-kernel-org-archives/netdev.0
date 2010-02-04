From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Thu, 4 Feb 2010 10:52:34 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1002041052020.15395@pobox.suse.cz>
References: <20100203133011.75aef1d3.sfr@canb.auug.org.au> <alpine.LNX.2.00.1002031136560.15395@pobox.suse.cz> <20100203.200402.17600564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, lsorense@csclub.uwaterloo.ca,
	netdev@vger.kernel.org, daniel@caiaq.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100203.200402.17600564.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Feb 2010, David Miller wrote:

> > I think the best thing is me dropping the net/ and drivers/net hunks of 
> > this patch and taking it through Davem's tree ... I have already dropped 
> > those hunks from my tree. Dave, the patch is below, please consider 
> > applying.
>  ...
> > From: Daniel Mack <daniel@caiaq.de>
> > Subject: [PATCH] net: fix 'lenght' typo in comments and code
> > 
> > Some misspelled occurences of 'octet' and some comments were also fixed
> > as I was on it.
> > 
> > Signed-off-by: Daniel Mack <daniel@caiaq.de>
> > Cc: Jiri Kosina <trivial@kernel.org>
> > Cc: Joe Perches <joe@perches.com>
> > Cc: Junio C Hamano <gitster@pobox.com>
> > Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> 
> This doesn't apply to net-next-2.6 at all:
> 
> error: patch failed: drivers/net/ppp_generic.c:1436
> error: drivers/net/ppp_generic.c: patch does not apply
> error: drivers/net/stmmac/gmac.c: does not exist in index
> error: drivers/net/stmmac/mac100.c: does not exist in index

Daniel, could you please refresh the drivers/net/ and net/ bits of your 
patch and resent it to netdev/Dave?

I have already dropped it from my queue.

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
