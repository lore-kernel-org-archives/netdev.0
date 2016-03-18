From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2 net-next] mediatek: unlock on error in mtk_tx_map()
Date: Fri, 18 Mar 2016 18:31:14 -0400 (EDT)
Message-ID: <20160318.183114.2001849673490296789.davem@davemloft.net>
References: <20160315071904.GI13560@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160315071904.GI13560@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Mar 2016 10:19:04 +0300

> There was a missing unlock on the error path.
> 
> Fixes: 656e705243fd ('net-next: mediatek: add support for MT7623 ethernet')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
