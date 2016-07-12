From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: mediatek: fix non static symbol warnings
Date: Tue, 12 Jul 2016 11:08:18 -0700 (PDT)
Message-ID: <20160712.110818.2218245588469646537.davem@davemloft.net>
References: <1468323404-2193-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbcGLSIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:08:19 -0400
In-Reply-To: <1468323404-2193-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 11:36:44 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warnings:
> 
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:79:5: warning:
>  symbol '_mtk_mdio_write' was not declared. Should it be static?
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:98:5: warning:
>  symbol '_mtk_mdio_read' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
