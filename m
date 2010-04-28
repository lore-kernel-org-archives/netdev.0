From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/17] sfc: Set PERIODIC_NOEVENT flag for
 MC_CMD_MAC_STATS
Date: Wed, 28 Apr 2010 12:46:12 -0700 (PDT)
Message-ID: <20100428.124612.179957482.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482972.2549.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756885Ab0D1TqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:46:07 -0400
In-Reply-To: <1272482972.2549.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:29:32 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> When set, an event is not sent whenever periodic MAC statistics are
> raised.  This avoids unnecessary wake-ups.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
