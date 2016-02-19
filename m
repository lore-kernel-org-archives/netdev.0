From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,V2] net: macb: make magic-packet property
 generic
Date: Fri, 19 Feb 2016 15:32:59 -0500 (EST)
Message-ID: <20160219.153259.1576466134100443929.davem@davemloft.net>
References: <1455664245-6842-1-git-send-email-sergio.prado@e-labworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	nicolas.ferre@atmel.com, gregory.clement@free-electrons.com,
	narmstrong@baylibre.com, michal.simek@xilinx.com,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422953AbcBSUdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:33:02 -0500
In-Reply-To: <1455664245-6842-1-git-send-email-sergio.prado@e-labworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergio Prado <sergio.prado@e-labworks.com>
Date: Tue, 16 Feb 2016 21:10:45 -0200

> As requested by Rob Herring on patch
> https://patchwork.ozlabs.org/patch/580862/.
> 
> This is a new property that it's still in net-next and has never been
> used in production, so we are not breaking anything with the
> incompatible binding change.
> 
> Signed-off-by: Sergio Prado <sergio.prado@e-labworks.com>

Applied, thanks.
