From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make of_set_phy_supported work with genphy driver
Date: Thu, 22 May 2014 15:44:01 -0400 (EDT)
Message-ID: <20140522.154401.1804662757425820920.davem@davemloft.net>
References: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaEVToD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:44:03 -0400
In-Reply-To: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 21 May 2014 15:29:43 +0200

> The mdio phys recently gained support for specifying the phy speed
> via devicetree. This currently only works with the hardware specific
> phy drivers but not with the genphy driver. This series fixes this.

Series applied to net-next, thanks.
