From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: bgmac: Remove redundant dev_err
 call in bgmac_probe()
Date: Wed, 13 Jul 2016 18:08:19 -0700 (PDT)
Message-ID: <20160713.180819.1694364344072616929.davem@davemloft.net>
References: <1468414017-2942-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbcGNBIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 21:08:20 -0400
In-Reply-To: <1468414017-2942-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Wed, 13 Jul 2016 12:46:57 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
