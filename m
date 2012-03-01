From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 01 Mar 2012 17:24:27 -0500 (EST)
Message-ID: <20120301.172427.782491081561180393.davem@davemloft.net>
References: <20120301133333.b8297fbd964c1d7aaf8c9f0b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcarlson@broadcom.com,
	mchan@broadcom.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120301133333.b8297fbd964c1d7aaf8c9f0b@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 1 Mar 2012 13:33:33 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/broadcom/tg3.c between commit 65ec698d1368 ("tg3:
> Fix tg3_get_stats64 for 5700 / 5701 devs") from the net tree and various
> commits from the net-next tree.
> 
> I just used the version from the net-next tree for today (assuming that
> this conflict will be fixed shortly).

I'll try to take care of this now, thanks Stephen.
