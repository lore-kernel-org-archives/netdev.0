From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/17] sfc: Consistently report short MCDI responses as
 EIO
Date: Wed, 28 Apr 2010 12:45:23 -0700 (PDT)
Message-ID: <20100428.124523.183031038.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482834.2549.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753590Ab0D1TpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:17 -0400
In-Reply-To: <1272482834.2549.18.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:27:14 +0100

> In some cases failing functions were returning 0 which is obviously wrong.
> In other cases they were returning inappropriate error codes.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
