From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: mediatek: remove .owner field for driver
Date: Wed, 06 Jul 2016 22:31:52 -0700 (PDT)
Message-ID: <20160706.223152.980979934196013750.davem@davemloft.net>
References: <1467811813-4864-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbcGGFcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:32:02 -0400
In-Reply-To: <1467811813-4864-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Wed,  6 Jul 2016 13:30:13 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Remove .owner field since calls to module_platform_driver() will
> set it automatically.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
