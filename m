From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: Fix error return code in xgbe_probe()
Date: Wed, 23 Jul 2014 14:55:21 -0700 (PDT)
Message-ID: <20140723.145521.2148794381539398091.davem@davemloft.net>
References: <1406077180-28852-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, grant.likely@linaro.org,
	robh+dt@kernel.org, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbaGWVzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:55:22 -0400
In-Reply-To: <1406077180-28852-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Wed, 23 Jul 2014 08:59:40 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the setting real tx queue
> count error handling case instead of 0.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
