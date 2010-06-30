From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] sfc: Add support for RX flow hash
 control
Date: Wed, 30 Jun 2010 14:10:59 -0700 (PDT)
Message-ID: <20100630.141059.256857913.davem@davemloft.net>
References: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
	<1277910388.2082.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756254Ab0F3VKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:10:46 -0400
In-Reply-To: <1277910388.2082.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 16:06:28 +0100

> Allow ethtool to query the number of RX rings, the fields used in RX
> flow hashing and the hash indirection table.
> 
> Allow ethtool to update the RX flow hash indirection table.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
