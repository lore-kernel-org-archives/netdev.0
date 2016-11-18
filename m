From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] lan78xx: relocate mdix setting to phy
 driver
Date: Fri, 18 Nov 2016 13:57:50 -0500 (EST)
Message-ID: <20161118.135750.2079082467742680999.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40966AA4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753843AbcKRS5w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:57:52 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40966AA4@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 17 Nov 2016 22:10:02 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Relocate mdix code to phy driver to be called at config_init().
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied, thank you.
