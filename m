From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Add SGMII Configuration for Marvell
 88E1145 Initialization
Date: Tue, 28 Oct 2014 17:00:51 -0400 (EDT)
Message-ID: <20141028.170051.1000189295296411637.davem@davemloft.net>
References: <1414351344-24042-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, vbridger@altera.com
To: vbridger@opensource.altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831AbaJ1VAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:00:53 -0400
In-Reply-To: <1414351344-24042-1-git-send-email-vbridger@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Sun, 26 Oct 2014 14:22:24 -0500

> Marvell phy 88E1145 configuration & initialization was missing a case
> for initializing SGMII mode. This patch adds that case.
> 
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>

Applied, thanks.
