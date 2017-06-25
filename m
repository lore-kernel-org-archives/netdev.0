From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: macb: add fixed-link node support
Date: Sun, 25 Jun 2017 15:22:13 -0400 (EDT)
Message-ID: <20170625.152213.861250473268873472.davem@davemloft.net>
References: <20170623145410.581-1-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@microchip.com,
        kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdFYTWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 15:22:16 -0400
In-Reply-To: <20170623145410.581-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Fri, 23 Jun 2017 16:54:10 +0200

> In case the MACB is directly connected to a
> non-mdio PHY/device, it should be possible to provide
> a fixed link configuration in the DT.
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>

Applied, thanks.
