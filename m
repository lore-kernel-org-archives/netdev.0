From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 0/4] net: fec: add interrupt coalescence
Date: Fri, 19 Sep 2014 15:37:58 -0400 (EDT)
Message-ID: <20140919.153758.2070105844475669082.davem@davemloft.net>
References: <1410902334-7827-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739AbaISTiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 15:38:00 -0400
In-Reply-To: <1410902334-7827-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Wed, 17 Sep 2014 05:18:50 +0800

> From: Frank Li <Frank.Li@freescale.com>
> improve error handle when parse queue number.
> add interrupt coalescence feature.
> 
> Change from v2 to v3
>  - add error check in fec_enet_set_coalesce
>  - fix a run time warning to get clock rate in interrupt
>  - fix commit message use TKT number
> 
> Change from v1 to v2
>  - fix indention
>  - use errata number instead of TKT

Series applied, thanks Frank.
