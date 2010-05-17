From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Sun, 16 May 2010 22:28:03 -0700 (PDT)
Message-ID: <20100516.222803.226762774.davem@davemloft.net>
References: <20100517120922.50d5e0fb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jengelh@medozas.de,
	chrisw@sous-sol.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100517120922.50d5e0fb.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 17 May 2010 12:09:22 +1000

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> include/linux/if_link.h between commit
> c02db8c6290bb992442fec1407643c94cc414375 ("rtnetlink: make SR-IOV VF
> interface symmetric") from Linus' tree and commit
> 10708f37ae729baba9b67bd134c3720709d4ae62 ("net: core: add IFLA_STATS64
> support") from the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix
> for a while.

I'll merge net-2.6 into net-next-2.6 to fix this for you, and
in fact your merge is exactly what I will use.

Thanks!
