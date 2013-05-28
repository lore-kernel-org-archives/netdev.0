From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v3] phy: allow flagging PHY devices as internal
Date: Mon, 27 May 2013 22:46:03 -0700 (PDT)
Message-ID: <20130527.224603.939199586314970626.davem@davemloft.net>
References: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	bhutchings@solarflare.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932798Ab3E1FqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:46:05 -0400
In-Reply-To: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Thu, 23 May 2013 12:11:10 +0100

> This small patch set updates libphy to allow PHY drivers to flag a
> specific PHY device as internal, which is then used to accurately
> report the transceiver type (internal vs external) in ethtool.
> 
> As far as I can tell we only have one in-tree driver for the moment
> which is known to be for internal PHYs.

Series applied, thanks Florian.
