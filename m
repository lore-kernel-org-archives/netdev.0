From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Mon, 20 Sep 2010 10:06:27 -0700 (PDT)
Message-ID: <20100920.100627.13732675.davem@davemloft.net>
References: <1284987700.3420.333.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757005Ab0ITRGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:06:08 -0400
In-Reply-To: <1284987700.3420.333.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Sep 2010 15:01:40 +0200

> ipv6 can be a module, we should test CONFIG_IPV6 and CONFIG_IPV6_MODULE
> to enable ipv6 bits in ip_gre.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6, thanks Eric.
