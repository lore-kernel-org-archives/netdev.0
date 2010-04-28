From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 27 Apr 2010 17:05:43 -0700 (PDT)
Message-ID: <20100427.170543.233869422.davem@davemloft.net>
References: <20100427112827.1f17be40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, alan@linux.intel.com, joe@perches.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100427112827.1f17be40.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 27 Apr 2010 11:28:27 +1000

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/e100.c between commit
> 401da6aea31ef69c2fcd260382adabdcf7ce820a ("e100: Fix the TX workqueue
> race") from Linus' tree and commit
> fa05e1ad1b61b37fb64a66794c11ab478e975c56 ("drivers/net/e100.c: Use
> pr_<level> and netif_<level>") from the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix
> for a while.

This should be resolved now that I pulled net-2.6 into net-next-2.6
earlier today.
