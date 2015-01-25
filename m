From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb
 board enet phy address
Date: Sat, 24 Jan 2015 21:55:12 -0800 (PST)
Message-ID: <20150124.215512.524443557800262525.davem@davemloft.net>
References: <1421743697-26918-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, stefan@agner.ch,
	linux-arm-kernel@lists.infradead.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbbAYFzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 00:55:13 -0500
In-Reply-To: <1421743697-26918-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 20 Jan 2015 16:48:17 +0800

> The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
> the commit add mdio node with un-correct phy address.
> 
> The patch just correct i.MX6sx sdb board enet phy address.
> 
> V2:
> * As Shawn's suggestion that unit-address should match 'reg' property, so
>   update ethernet-phy unit-address.
> 
> Acked-by: Stefan Agner <stefan@agner.ch>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied.
