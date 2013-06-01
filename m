From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: add reverse MII PHY connection type
Date: Fri, 31 May 2013 17:20:27 -0700 (PDT)
Message-ID: <20130531.172027.651766088600576429.davem@davemloft.net>
References: <1369750041-30396-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab3FAAU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:20:28 -0400
In-Reply-To: <1369750041-30396-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Tue, 28 May 2013 15:07:21 +0100

> The PHY library currently does not know about the the reverse MII
> connection type. Add it to the list of supported PHY modes and update
> of_get_phy_mode() to support it and look for the string "rev-mii".
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
