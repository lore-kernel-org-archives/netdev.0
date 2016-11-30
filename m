From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: phy: broadcom: Support for PHY
 counters
Date: Wed, 30 Nov 2016 10:22:48 -0500 (EST)
Message-ID: <20161130.102248.1508476415464032953.davem@davemloft.net>
References: <20161129175718.20213-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33228 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753817AbcK3PWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:22:50 -0500
In-Reply-To: <20161129175718.20213-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Nov 2016 09:57:16 -0800

> This patch series adds support for reading the Broadcom PHYs internal counters.
> 
> Changes in v3:
> 
> - fixed the allocation of priv->stats in bcm7xxx
> 
> Changes in v2:
> 
> - fixed modular build reported by kbuild
> 
> - constify array of stats

Series applied, thanks Florian.
