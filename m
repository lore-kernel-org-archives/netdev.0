From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/2] net: phy: DP83822 initial driver submission
Date: Wed, 11 Oct 2017 14:14:48 -0700 (PDT)
Message-ID: <20171011.141448.1351842413548216785.davem@davemloft.net>
References: <20171010174256.21930-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        Woojung.Huh@microchip.com, afd@ti.com
To: dmurphy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdJKVOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:14:49 -0400
In-Reply-To: <20171010174256.21930-1-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Murphy <dmurphy@ti.com>
Date: Tue, 10 Oct 2017 12:42:55 -0500

> Add support for the TI  DP83822 10/100Mbit ethernet phy.
> 
> The DP83822 provides flexibility to connect to a MAC through a
> standard MII, RMII or RGMII interface.
> 
> In addition the DP83822 needs to be removed from the DP83848 driver
> as the WoL support is added here for this device.
> 
> Datasheet:
> http://www.ti.com/product/DP83822I/datasheet
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Applied to net-next.
