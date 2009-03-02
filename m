From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] sfc: SFT9001/SFN4111T: Check PHY boot status
 during board initialisation
Date: Mon, 02 Mar 2009 03:26:23 -0800 (PST)
Message-ID: <20090302.032623.137350616.davem@davemloft.net>
References: <1235775847.3164.6.camel@achroite>
	<1235776005.3164.18.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753765AbZCBL0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:26:41 -0500
In-Reply-To: <1235776005.3164.18.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Feb 2009 23:06:45 +0000

> During SFN4111T initialisation, check whether the PHY boot status
> indicates a bad firmware checksum.  If so, prepare to reflash rather
> than continuing with normal initialisation.
> 
> Remove redundant PHY boot status check from tenxpress_phy_init().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
