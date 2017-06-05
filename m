From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: phy: smsc: Implement PHY statistics
Date: Sun, 04 Jun 2017 21:36:53 -0400 (EDT)
Message-ID: <20170604.213653.1012564597223222487.davem@davemloft.net>
References: <1496512836-22198-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdFEBgz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 21:36:55 -0400
In-Reply-To: <1496512836-22198-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  3 Jun 2017 20:00:36 +0200

> Most of the PHYs supported by the SMSC driver have a counter of symbol
> errors. This is 16 bit wide and wraps around when it reaches its
> maximum value.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Reviewed-By: Woojung Huh <Woojung.Huh@microchip.com>
> ---
> v2:
> 	Align members
> 	Add Reviewed-by's

Applied.
