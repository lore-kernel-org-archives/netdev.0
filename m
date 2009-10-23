From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: 10Xpress: Report support for pause frames
Date: Thu, 22 Oct 2009 18:31:49 -0700 (PDT)
Message-ID: <20091022.183149.10311155.davem@davemloft.net>
References: <1256250314.2785.22.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbZJWBb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 21:31:26 -0400
In-Reply-To: <1256250314.2785.22.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 22 Oct 2009 23:25:14 +0100

> Commits 27fbc7d 'mdio: Expose pause frame advertising flags to ethtool'
> and c634263 'sfc: 10Xpress: Initialise pause advertising flags'
> added to our reported advertising flags.
> 
> efx_mdio_set_settings() requires that all advertising flags are
> also present in the supported flags, so make sure that is true.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
