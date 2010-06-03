From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Store port number in net_device::dev_id
Date: Thu, 03 Jun 2010 03:29:47 -0700 (PDT)
Message-ID: <20100603.032947.10563469.davem@davemloft.net>
References: <1275511200.2115.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50301
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCK3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:37 -0400
In-Reply-To: <1275511200.2115.23.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 02 Jun 2010 21:39:56 +0100

> This exposes the port number to userland through sysfs.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Following on from the earlier discussion of dev_id, here's the necessary
> change for sfc.  This depends on commit dd8f61d "sfc: Get port number
> from CS_PORT_NUM, not PCI function number".  Please consider including
> both of these in net-2.6.

Both added to net-2.6
