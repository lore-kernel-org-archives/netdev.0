From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] phy: keep pause flags in phy driver features
Date: Wed, 17 Feb 2016 10:48:59 -0500 (EST)
Message-ID: <20160217.104859.1010107210386086622.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D404AC676@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161412AbcBQPtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 10:49:01 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404AC676@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 11 Feb 2016 17:29:47 +0000

> genphy_config_init() masked out pause flags set in phy driver structure.
> Pause flags needs to be preserved in phydev->supported &
> phydev->advertising.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied, thanks.
