From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/17] sfc: Read MEM_STAT for SRM_PERR as well as
 MEM_PERR errors
Date: Wed, 28 Apr 2010 12:45:57 -0700 (PDT)
Message-ID: <20100428.124557.246509291.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482932.2549.24.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932067Ab0D1Tpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:51 -0400
In-Reply-To: <1272482932.2549.24.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:28:52 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Parity errors in different blocks of SRAM may set one of two different
> interrupt flags.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
