From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: phy: simplify phy_supported_speeds()
Date: Mon, 17 Apr 2017 13:25:38 -0400 (EDT)
Message-ID: <20170417.132538.949189252161071190.davem@davemloft.net>
References: <20170406100033.GA24671@n2100.armlinux.org.uk>
        <E1cygzo-0002s5-T0@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752398AbdDQRZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:25:39 -0400
In-Reply-To: <E1cygzo-0002s5-T0@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Thu, 13 Apr 2017 16:49:20 +0100

> Simplify the loop in phy_supported_speeds().
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Also applied to net-next, thanks.
