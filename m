From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: phy: Add MAC-IF driver for Microsemi
 PHYs.
Date: Tue, 20 Sep 2016 04:41:00 -0400 (EDT)
Message-ID: <20160920.044100.44266551800107029.davem@davemloft.net>
References: <1474279434-14583-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com, andrew@lunn.ch
To: Raju.Lakkaraju@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbcITIr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:47:29 -0400
In-Reply-To: <1474279434-14583-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date: Mon, 19 Sep 2016 15:33:54 +0530

> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> All the review comments updated and resending for review.
> 
> This is MAC interface feature.
> Microsemi PHY can support RGMII, RMII or GMII/MII interface between MAC and PHY.
> MAC-IF function program the right value based on Device tree configuration.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Applied.
