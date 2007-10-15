From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] [IPV6]: Add skb_is_gso_v6
Date: Mon, 15 Oct 2007 02:06:24 -0700 (PDT)
Message-ID: <20071015.020624.70200288.davem@davemloft.net>
References: <47109E8A.8080205@myri.com>
	<47109EFC.3020601@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757837AbXJOJGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:06:20 -0400
In-Reply-To: <47109EFC.3020601@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brice Goglin <brice@myri.com>
Date: Sat, 13 Oct 2007 12:33:32 +0200

> Add skb_is_gso_v6().
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

No objections from me:

Acked-by: David S. Miller <davem@davemloft.net>

Jeff, it's simplest if you just merge this in with the
rest of the myri10ge patches, so please do so.

Thanks!
