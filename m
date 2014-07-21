From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: mvpp2: Remove redundant dev_err call in
 mvpp2_port_probe()
Date: Sun, 20 Jul 2014 22:27:17 -0700 (PDT)
Message-ID: <20140720.222717.1517718332792494328.davem@davemloft.net>
References: <1405864637-13737-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	ezequiel.garcia@free-electrons.com, mw@semihalf.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbaGUF1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:27:17 -0400
In-Reply-To: <1405864637-13737-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Sun, 20 Jul 2014 21:57:17 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
