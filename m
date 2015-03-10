From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 10 Mar 2015 18:34:32 -0400 (EDT)
Message-ID: <20150310.183432.983434129392290441.davem@davemloft.net>
References: <20150310120842.6dfa6c2b@canb.auug.org.au>
	<20150309.234329.425011226766680524.davem@davemloft.net>
	<20150311084830.0bc6dffd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joshc@ni.com,
	boris.brezillon@free-electrons.com, cyrille.pitchen@atmel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150311084830.0bc6dffd@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 11 Mar 2015 08:48:30 +1100

> Just wondering if you got that merge right?  Here is the diff from what
> I did yesterday to what you have in net-next:
 ...
> That section was removed by commit 421d9df0628b ("net/macb: merge
> at91_ether driver into macb driver") and I presumed its effect was
> moved into macb_probe().

Indeed, you're right, good catch.

Fixed and pushed out to net-next, thanks!
