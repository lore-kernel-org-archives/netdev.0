From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 11/17] sfc: Move mdio_lock to struct
 falcon_nic_data
Date: Fri, 03 Dec 2010 09:09:35 -0800 (PST)
Message-ID: <20101203.090935.48503397.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333655.3259.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753083Ab0LCRJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:09:09 -0500
In-Reply-To: <1291333655.3259.34.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:47:35 +0000

> We only have direct access to MDIO on Falcon, so move this out of
> struct efx_nic.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
