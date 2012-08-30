From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v3] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Thu, 30 Aug 2012 12:55:35 -0400 (EDT)
Message-ID: <20120830.125535.1084896704465801840.davem@davemloft.net>
References: <1345835453-8611-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, swarren@wwwdotorg.org,
	ddaney.cavm@gmail.com, devicetree-discuss@lists.ozlabs.org,
	netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab2H3Qzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:55:37 -0400
In-Reply-To: <1345835453-8611-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Fri, 24 Aug 2012 14:10:53 -0500

> Add support for an MDIO bus multiplexer controlled by a simple memory-mapped
> device, like an FPGA.  The device must be memory-mapped and contain only
> 8-bit registers (which keeps things simple).
> 
> Tested on a Freescale P5020DS board which uses the "PIXIS" FPGA attached
> to the localbus.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next, thanks.
