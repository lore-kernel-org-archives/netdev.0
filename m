From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sfc: fix sparse non static symbol warning
Date: Thu, 19 Dec 2013 15:00:48 -0500 (EST)
Message-ID: <20131219.150048.1705104019951766324.davem@davemloft.net>
References: <CAPgLHd8gaC5j0Ts7SXdDwFPKNpvm2AR_fxHhT3KSNs2Jsi_Lyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3LSUAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:00:50 -0500
In-Reply-To: <CAPgLHd8gaC5j0Ts7SXdDwFPKNpvm2AR_fxHhT3KSNs2Jsi_Lyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 17 Dec 2013 11:08:10 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warning:
> 
> drivers/net/ethernet/sfc/falcon.c:2601:6: warning:
>  symbol 'falcon_pull_nic_stats' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Looks good, applied, thanks.
