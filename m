From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for
 Microsemi PHYs.
Date: Wed, 08 Feb 2017 13:29:19 -0500 (EST)
Message-ID: <20170208.132919.1842467149726317786.davem@davemloft.net>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com, andrew@lunn.ch
To: Raju.Lakkaraju@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751376AbdBHS3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:29:21 -0500
In-Reply-To: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date: Tue, 7 Feb 2017 19:10:26 +0530

> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> LED Mode:
> Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> status information that can be selected by setting LED mode.
> 
> LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get
> from Device Tree.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Applied, thank you.
