From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcm63xx_enet: Fix build failure with
 phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 21:56:43 -0500 (EST)
Message-ID: <20161115.215643.2070933046596523141.davem@davemloft.net>
References: <20161116022109.26935-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752445AbcKPC4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 21:56:48 -0500
In-Reply-To: <20161116022109.26935-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 15 Nov 2016 18:21:09 -0800

> Introduced a typo making the driver no longer build, *sigh*.
> 
> Fixes: 42469bf5d9bb ("net: bcm63xx_enet: Utilize phy_ethtool_nway_reset")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
