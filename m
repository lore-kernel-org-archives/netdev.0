From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] mdio: Expose pause frame advertising flags to
 ethtool
Date: Tue, 13 Oct 2009 00:02:02 -0700 (PDT)
Message-ID: <20091013.000202.225256676.davem@davemloft.net>
References: <1255375597.2931.13.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933339AbZJMHCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:02:06 -0400
In-Reply-To: <1255375597.2931.13.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 12 Oct 2009 20:26:37 +0100

> In mdio45_ethtool_gset_npage() and mdio45_ethtool_gset(), check MDIO
> pause frame advertising flags and set the corresponding ethtool flags.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6
