From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/5] dsa: add Microchip KSZ9477 DSA driver
Date: Wed, 31 May 2017 14:28:30 -0400 (EDT)
Message-ID: <20170531.142830.1153280352895864825.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40AA4D4C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdEaS2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:28:33 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AA4D4C@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Wed, 31 May 2017 00:00:34 +0000

> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> This series of patches is for Microchip KSZ9477 DSA driver.
> KSZ9477 is 7 ports GigE switch with numerous advanced features.
> 5 ports are 10/100/1000 Mbps internal PHYs and 2 ports have
> Interfaces to SGMII, RGMII, MII or RMII.
> 
> This patch supports VLAN, MDB, FDB and port mirroring offloads.
> 
> Welcome reviews and comments from community.
> 
> Note: Tests are performed on internal development board.

Series applied, thanks.
