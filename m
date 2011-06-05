From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Sun, 05 Jun 2011 14:08:01 -0700 (PDT)
Message-ID: <20110605.140801.1144137337172959622.davem@davemloft.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
	<20110605083445.GT16318@ibawizard.net>
	<20110605085948.GB16018@acer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ynezz@true.cz, netdev@vger.kernel.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	kernel@wantstofly.org, linux-arm-kernel@lists.infradead.org
To: mika.westerberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017Ab1FEVJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:09:17 -0400
In-Reply-To: <20110605085948.GB16018@acer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@iki.fi>
Date: Sun, 5 Jun 2011 11:59:48 +0300

> It looks like David Miller (CC'd) has been taking care of ep93xx_eth.c maybe
> he knows this better.

Someone needs to step up and take over as the real maintainer of this
driver.  The way the driver is currently being hacked on is
unsustainable.
