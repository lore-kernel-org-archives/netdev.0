From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: another bug fix related to
 dst_neigh_lookup/dst_neigh_lookup_skb
Date: Wed, 13 Mar 2013 10:39:40 -0400 (EDT)
Message-ID: <20130313.103940.539407105030607593.davem@davemloft.net>
References: <CAABZP2xsVauGarKa1yfWOHAmi9Z+B+Au3ZYa-QkM1hA4b4PypA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, trivial@kernel.org
To: zhouzhouyi@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAABZP2xsVauGarKa1yfWOHAmi9Z+B+Au3ZYa-QkM1hA4b4PypA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Wed, 13 Mar 2013 16:40:49 +0800

> I do a
> /home/zzy/linux-stable#find . -name "*.c"|xargs grep -A 2 dst_neigh_lookup
> and find that there are two places in drivers/infiniband/hw/cxgb4/cm.c
> do not treat the error return of dst_neigh_lookup/dst_neigh_lookup_skb

This patch is also corrupted by your email client.

> 
> Signed-off-by: Zhouyi Zhou <zhouzhouyi <at> gmail.com>

Do not write your email address in your signoff in this way,
you use real email address with a real "@" character rather
than this " <at> " thing.
