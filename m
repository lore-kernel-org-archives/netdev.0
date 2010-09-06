From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] wan: make driver strings const
Date: Mon, 06 Sep 2010 13:32:35 -0700 (PDT)
Message-ID: <20100906.133235.28796964.davem@davemloft.net>
References: <20100901.182014.141246825.davem@davemloft.net>
	<20100901.191921.66727586.davem@davemloft.net>
	<20100902172935.469cfeeb@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, andrew.hendry@gmail.com,
	elendil@planet.nl, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754165Ab0IFUcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:32:17 -0400
In-Reply-To: <20100902172935.469cfeeb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 2 Sep 2010 17:29:35 -0700

> Subject: wan: make read-only data const
> 
> Change several wan drivers to make strings and other initialize
> only parameters const.
> 
> Compile tested only (with no new warnings)
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
