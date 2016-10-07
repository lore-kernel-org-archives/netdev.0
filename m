From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: phy: Add Wake-on-LAN driver for
 Microsemi PHYs.
Date: Thu, 06 Oct 2016 20:48:26 -0400 (EDT)
Message-ID: <20161006.204826.561373380580386700.davem@davemloft.net>
References: <1475657367-13600-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com, andrew@lunn.ch
To: Raju.Lakkaraju@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcJGAs3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:48:29 -0400
In-Reply-To: <1475657367-13600-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date: Wed, 5 Oct 2016 14:19:27 +0530

> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Wake-on-LAN (WoL) is an Ethernet networking standard that allows 
> a computer/device to be turned on or awakened by a network message.
> 
> VSC8531 PHY can support this feature configure by driver set function.
> WoL status get by driver get function.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Applied.
