From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: Implenent ethtool::nway_reset for a
 few drivers
Date: Wed, 16 Nov 2016 13:44:26 -0500 (EST)
Message-ID: <20161116.134426.646312767588173259.davem@davemloft.net>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, tremyfr@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753625AbcKPSob (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:44:31 -0500
In-Reply-To: <20161115191949.15361-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 15 Nov 2016 11:19:44 -0800

> This patch series depends on "net: phy: Centralize auto-negotation restart"
> since it provides phy_ethtool_nway_reset as a helper function.
> 
> The drivers here already support PHYLIB, so there really is no reason why
> restarting auto-negotiation would not be possible with these.

Series applied, thanks Florian.
