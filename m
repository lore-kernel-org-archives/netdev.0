From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: dsa: Fix non static symbol warning
Date: Tue, 12 Jul 2016 11:49:48 -0700 (PDT)
Message-ID: <20160712.114948.848216581678020682.davem@davemloft.net>
References: <1468337050-10866-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbcGLSty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:49:54 -0400
In-Reply-To: <1468337050-10866-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 15:24:10 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warning:
> 
> net/dsa/dsa2.c:680:6: warning:
>  symbol '_dsa_unregister_switch' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
