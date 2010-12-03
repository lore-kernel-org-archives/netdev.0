From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 04/17] sfc: Read-to-clear LM87
 alarm/interrupt status at start of day
Date: Fri, 03 Dec 2010 09:08:51 -0800 (PST)
Message-ID: <20101203.090851.104063781.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333591.3259.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452Ab0LCRIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:24 -0500
In-Reply-To: <1291333591.3259.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:46:31 +0000

> We do not want to shut down the board based on a fault that has
> already been cleared.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
