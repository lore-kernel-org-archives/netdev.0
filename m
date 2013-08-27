From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Tue, 27 Aug 2013 12:23:04 -0400 (EDT)
Message-ID: <20130827.122304.330396034037685430.davem@davemloft.net>
References: <20130826.162135.1765443562851401512.davem@davemloft.net>
	<521C0104.2070906@windriver.com>
	<20130827092856.GC7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, saurabh.mohan@vyatta.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab3H0QXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 12:23:06 -0400
In-Reply-To: <20130827092856.GC7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 27 Aug 2013 11:28:56 +0200

> I'd take this into ipsec-next and update the the ipv6 vti patch
> according to your changes if David does not mind.

This is fine.
