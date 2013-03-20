From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: make local function fec_poll_controller()
 static
Date: Wed, 20 Mar 2013 13:26:32 -0400 (EDT)
Message-ID: <20130320.132632.1512708134586904282.davem@davemloft.net>
References: <CAPgLHd-ZLKjHdqc_Bm44co+9eTF48TOg9zY8c1jbqeG+jnn3GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	Frank.Li@freescale.com, shawn.guo@linaro.org,
	fabio.estevam@freescale.com, s.hauer@pengutronix.de,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab3CTR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:26:35 -0400
In-Reply-To: <CAPgLHd-ZLKjHdqc_Bm44co+9eTF48TOg9zY8c1jbqeG+jnn3GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 20 Mar 2013 23:06:11 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> fec_poll_controller() was not declared. It should be static.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
