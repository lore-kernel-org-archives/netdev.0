From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: phy: dp83867: workaround incorrect RX_CTRL
 pin strap
Date: Wed, 05 Jul 2017 09:25:37 +0100 (WEST)
Message-ID: <20170705.092537.2229563531210589008.davem@davemloft.net>
References: <cover.1499162046.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, andrew@lunn.ch,
        f.fainelli@gmail.com, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, tony@atomide.com,
        linux-omap@vger.kernel.org, grygorii.strashko@ti.com
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdGEIZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:25:45 -0400
In-Reply-To: <cover.1499162046.git.nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sekhar Nori <nsekhar@ti.com>
Date: Tue, 4 Jul 2017 16:23:22 +0530

> This patch series adds workaround for incorrect RX_CTRL pin strap
> setting that can be found on some TI boards.
> 
> This is required to be complaint to PHY datamanual specification.

Series applied.
