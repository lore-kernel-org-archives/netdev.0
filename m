From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: phy: Fix PHY unbind crash
Date: Mon, 20 Feb 2017 10:15:28 -0500 (EST)
Message-ID: <20170220.101528.1140867873799745659.davem@davemloft.net>
References: <20170218000734.32590-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbdBTPQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:16:34 -0500
In-Reply-To: <20170218000734.32590-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 17 Feb 2017 16:07:32 -0800

> This fixes crashes when the PHY driver is no longer bound to the device.
> 
> There is still a fair amount of work to be done to get the unbind -> bind
> sequent to result in a functional state, but that will be net-next material.
> 
> These two problems existed for as long as PHYLIB as been around.

Series applied, thanks.
