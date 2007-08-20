From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phy layer: fix genphy_setup_forced (don't reset)
Date: Mon, 20 Aug 2007 14:43:06 -0500
Message-ID: <8A4DE44B-A030-4794-8832-E9C731379BD1@freescale.com>
References: <20070817065445.GH13994@moe.telargo.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:35314 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbXHTTn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 15:43:26 -0400
In-Reply-To: <20070817065445.GH13994@moe.telargo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 17, 2007, at 01:54, Domen Puncer wrote:

> Writing BMCR_RESET bit will reset MII_BMCR to default values. This is
> clearly not what we want.
>
>
> Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

Acked-by: Andy Fleming <afleming@freescale.com>

I could have sworn there was a patch that did this, already, but it  
must have lost steam somewhere.

Andy
