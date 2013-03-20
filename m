From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] lpc_eth: fix error return code in
 lpc_eth_drv_probe()
Date: Wed, 20 Mar 2013 12:19:48 -0400 (EDT)
Message-ID: <20130320.121948.1581171968783524870.davem@davemloft.net>
References: <CAPgLHd-49BjXc1pwxhSCExNwTuM9rg4Yj6A2PyqnUq=fgm3YKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	stigge@antcom.de, edumazet@google.com, gregkh@linuxfoundation.org,
	jiri@resnulli.us, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab3CTQTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:19:52 -0400
In-Reply-To: <CAPgLHd-49BjXc1pwxhSCExNwTuM9rg4Yj6A2PyqnUq=fgm3YKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 20 Mar 2013 20:21:48 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
