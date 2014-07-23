From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hyperv: Fix error return code in netvsc_init_buf()
Date: Wed, 23 Jul 2014 14:56:00 -0700 (PDT)
Message-ID: <20140723.145600.2058227715036113961.davem@davemloft.net>
References: <1406077235-29095-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	yongjun_wei@trendmicro.com.cn, devel@linuxdriverproject.org,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbaGWV4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:56:00 -0400
In-Reply-To: <1406077235-29095-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Wed, 23 Jul 2014 09:00:35 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENOMEM from the kalloc error handling
> case instead of 0.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
