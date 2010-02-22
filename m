From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] b44: Set PHY address to NO_PHY if reset fails.
Date: Mon, 22 Feb 2010 15:46:39 -0800 (PST)
Message-ID: <20100222.154639.158520764.davem@davemloft.net>
References: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111Ab0BVXqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:21 -0500
In-Reply-To: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 20 Feb 2010 21:55:25 +0100

> Do a PHY reset to test if there is an active phy and set the PHY address
> to B44_PHY_ADDR_NO_PHY in case of an not active phy. This is needed for
> the Linksys WRTSL54GS and Asus WL-500W.
> This patch was used in OpenWRT for a long time.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
