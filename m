From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: QT202x: Remove unreliable MMD check at
 initialisation
Date: Tue, 19 Jan 2010 02:00:47 -0800 (PST)
Message-ID: <20100119.020047.23794901.davem@davemloft.net>
References: <1263829636.3667.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755577Ab0ASKAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:00:37 -0500
In-Reply-To: <1263829636.3667.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 18 Jan 2010 15:47:16 +0000

> From: Matthew Slattery <mslattery@solarflare.com>
> 
> Checking the PHY XS MMD here is unnecessary and can give false negatives.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

