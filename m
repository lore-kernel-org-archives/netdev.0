From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: mvpp2: Fix error return code in
 mvpp2_probe()
Date: Sun, 20 Jul 2014 22:27:22 -0700 (PDT)
Message-ID: <20140720.222722.455470902484170683.davem@davemloft.net>
References: <1405864963-14217-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	ezequiel.garcia@free-electrons.com, mw@semihalf.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaGUF1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:27:23 -0400
In-Reply-To: <1405864963-14217-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Sun, 20 Jul 2014 22:02:43 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENODEV from the no ports enabled error handling
> case instead of 0.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
