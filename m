From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix mv643xx_eth for disabled autoneg
Date: Thu, 07 Mar 2013 16:18:07 -0500 (EST)
Message-ID: <20130307.161807.944944807608782921.davem@davemloft.net>
References: <1362592142-4049-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, netdev@vger.kernel.org
To: phil.sutter@viprinet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758688Ab3CGVSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:18:09 -0500
In-Reply-To: <1362592142-4049-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil.sutter@viprinet.com>
Date: Wed,  6 Mar 2013 18:49:02 +0100

> When autoneg has been disabled in the PHY (Marvell 88E1118 here), auto
> negotiation between MAC and PHY seem non-functional anymore. The only
> way I found to workaround this is to manually configure the MAC with the
> settings sent to the PHY earlier.
> 
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>

Applied, thanks.
