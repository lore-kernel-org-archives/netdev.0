From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: remove unused including <linux/version.h>
Date: Sun, 07 Oct 2012 14:51:13 -0400 (EDT)
Message-ID: <20121007.145113.358911913612359265.davem@davemloft.net>
References: <CAPgLHd-AeX16JeZJv6D6K_wFr2_r4Zp=Q_Hw5BK-iF+mSWRE4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab2JGSvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:51:15 -0400
In-Reply-To: <CAPgLHd-AeX16JeZJv6D6K_wFr2_r4Zp=Q_Hw5BK-iF+mSWRE4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 7 Oct 2012 21:23:06 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Remove including <linux/version.h> that don't need it.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
