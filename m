From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: fix error return code in bfin_mac_probe()
Date: Wed, 08 May 2013 13:15:15 -0700 (PDT)
Message-ID: <20130508.131515.1462292031715395562.davem@davemloft.net>
References: <CAPgLHd-=Cg0hvmerge=oUJvypMU7=HcuDmAgLHNSb8Tay5OVdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, jiri@resnulli.us,
	gregkh@linuxfoundation.org, konszert@marvell.com,
	yongjun_wei@trendmicro.com.cn,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab3EHUPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:15:16 -0400
In-Reply-To: <CAPgLHd-=Cg0hvmerge=oUJvypMU7=HcuDmAgLHNSb8Tay5OVdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 7 May 2013 20:23:38 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
