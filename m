From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] net: sh_eth: modify the PHY_INTERFACE_MODE
Date: Mon, 14 Mar 2011 14:11:03 -0700 (PDT)
Message-ID: <20110314.141103.48516316.davem@davemloft.net>
References: <4D75E1F1.5090306@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754351Ab1CNVK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:10:26 -0400
In-Reply-To: <4D75E1F1.5090306@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 08 Mar 2011 16:59:45 +0900

> The previous code had hardcoded the PHY_INTERFACE_MODE_MII of phy_connect.
> So some Gigabit PHYs will not behave correctly.
> The patch adds the phy_interface in sh_eth_plat_data, so we can select
> the phy interface.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
