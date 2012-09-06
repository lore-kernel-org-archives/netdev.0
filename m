From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/6] net: pxaficp_ir: add irq resources
Date: Thu, 06 Sep 2012 16:46:07 -0400 (EDT)
Message-ID: <20120906.164607.272336805646397930.davem@davemloft.net>
References: <1346960563-18689-1-git-send-email-robherring2@gmail.com>
	<1346960563-18689-3-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	arnd@arndb.de, olof@lixom.net, linus.walleij@linaro.org,
	rob.herring@calxeda.com, samuel@sortiz.org, eric.y.miao@gmail.com,
	haojian.zhuang@gmail.com, netdev@vger.kernel.org
To: robherring2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab2IFUqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 16:46:12 -0400
In-Reply-To: <1346960563-18689-3-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <robherring2@gmail.com>
Date: Thu,  6 Sep 2012 14:42:39 -0500

> From: Rob Herring <rob.herring@calxeda.com>
> 
> In order to remove dependency on mach/irqs.h, add platform device
> resources for irqs.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Feel free to put this in via the ARM tree.

Acked-by: David S. Miller <davem@davemloft.net>
