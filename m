From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/17] sfc: Clean up efx_nic::irq_zero_count
Date: Wed, 28 Apr 2010 12:46:27 -0700 (PDT)
Message-ID: <20100428.124627.232768598.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272483000.2549.30.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932079Ab0D1TqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:46:21 -0400
In-Reply-To: <1272483000.2549.30.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:30:00 +0100

> There is no need for this to be unsigned long; make it unsigned int.
> It does need a line in kernel-doc, so add that.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
