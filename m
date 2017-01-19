From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] phy: increase size of MII_BUS_ID_SIZE and
 bus_id
Date: Thu, 19 Jan 2017 11:52:46 -0500 (EST)
Message-ID: <20170119.115246.542469330543728589.davem@davemloft.net>
References: <1484841904-19313-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se, magnus.oberg@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753350AbdASRBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:01:04 -0500
In-Reply-To: <1484841904-19313-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Thu, 19 Jan 2017 17:05:04 +0100

> Some bus names are pretty long and do not fit into
> 17 chars. Increase therefore MII_BUS_ID_SIZE and
> phy_fixup.bus_id to larger number. Now mii_bus.id
> can host larger name.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>

Applied.
