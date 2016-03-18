From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2 net-next] mediatek: checking for IS_ERR() instead
 of NULL
Date: Fri, 18 Mar 2016 18:31:08 -0400 (EDT)
Message-ID: <20160318.183108.984979448291543214.davem@davemloft.net>
References: <20160315071849.GH13560@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160315071849.GH13560@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Mar 2016 10:18:49 +0300

> of_phy_connect() returns NULL on error, it never returns error pointers.
> 
> Fixes: 656e705243fd ('net-next: mediatek: add support for MT7623 ethernet')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
