From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Wed, 28 Nov 2012 11:46:02 -0500 (EST)
Message-ID: <20121128.114602.1208211617672057364.davem@davemloft.net>
References: <1353114559.10798.66.camel@edumazet-glaptop>
	<20121119.191002.1995098917961576324.davem@davemloft.net>
	<50B3850C.4070902@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	herbert@gondor.hengli.com.au
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2K1QqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:46:05 -0500
In-Reply-To: <50B3850C.4070902@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Mon, 26 Nov 2012 10:04:44 -0500

> How do you feel about the patchset I posted on 11/14/2012
> ([PATCH net-next 0/3] myri10ge: LRO to GRO conversion,
> http://marc.info/?l=linux-netdev&m=135289838223920&w=2)
> which moves myri10ge from LRO to GRO?
> 
> Specifically, if doing vlan decap in GRO is not OK, then how
> about doing it in the driver?

I'm going to trust Eric's judgment on this one, as he has been
thinking more about the long term GRO issues than I have.

Thanks.
