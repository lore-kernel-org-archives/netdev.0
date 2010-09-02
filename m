From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] wan: make driver strings const
Date: Wed, 01 Sep 2010 18:20:14 -0700 (PDT)
Message-ID: <20100901.182014.141246825.davem@davemloft.net>
References: <20100901181515.02c5abdc@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, andrew.hendry@gmail.com,
	elendil@planet.nl, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754481Ab0IBBT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:19:57 -0400
In-Reply-To: <20100901181515.02c5abdc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 1 Sep 2010 18:15:15 -0700

> Change several wan drivers to make strings and other initialize
> only parameters const.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
