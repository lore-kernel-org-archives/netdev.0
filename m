From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/5] ipv6: addrconf: fix 48 bit 6lowpan
 autoconfiguration
Date: Thu, 23 Feb 2017 14:05:01 -0500 (EST)
Message-ID: <20170223.140501.1497931464135952468.davem@davemloft.net>
References: <20170221103811.1506-1-luiz.dentz@gmail.com>
        <20170221103811.1506-6-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, patrik.flykt@linux.intel.com,
        aar@pengutronix.de, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: luiz.dentz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdBWTMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 14:12:33 -0500
In-Reply-To: <20170221103811.1506-6-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Date: Tue, 21 Feb 2017 12:38:10 +0200

> From: Alexander Aring <aar@pengutronix.de>
> 
> This patch adds support for 48 bit 6LoWPAN address length
> autoconfiguration which is the case for BTLE 6LoWPAN.
> 
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

This is fine and I have no problem with it going via the bluetooth
tree, thanks.

Acked-by: David S. Miller <davem@davemloft.net>
