From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] sfc: 10Xpress: Initialise pause advertising flags
Date: Tue, 13 Oct 2009 00:02:08 -0700 (PDT)
Message-ID: <20091013.000208.109858649.davem@davemloft.net>
References: <1255375627.2931.15.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933489AbZJMHCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:02:12 -0400
In-Reply-To: <1255375627.2931.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 12 Oct 2009 20:27:07 +0100

> The mdio module now handles reconfiguration of pause advertising
> through ethtool, but not initialisation.  Add the necessary
> initialisation to tenxpress_phy_init().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6

Thanks!
