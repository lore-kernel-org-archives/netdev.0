From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: bcm7xxx: update workaround to fix
 100BaseT corner cases
Date: Mon, 08 Jun 2015 15:55:54 -0700 (PDT)
Message-ID: <20150608.155554.263308205832736485.davem@davemloft.net>
References: <1433786720-5920-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201AbbFHWzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:55:55 -0400
In-Reply-To: <1433786720-5920-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  8 Jun 2015 11:05:20 -0700

> Update the AFE_TX_CONFIG value to solve marginal rise/fall issues
> observed when the link is operating in 100BaseT. This workaround applies
> to GPHY revisions D0, E0 and newer.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
