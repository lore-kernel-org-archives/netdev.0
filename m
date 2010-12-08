From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: call dev_queue_xmit_nit() after
 skb_dst_drop()
Date: Wed, 08 Dec 2010 10:38:33 -0800 (PST)
Message-ID: <20101208.103833.246528665.davem@davemloft.net>
References: <1291706359.2769.17.camel@edumazet-laptop>
	<1291717837.2695.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753896Ab0LHSiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:38:06 -0500
In-Reply-To: <1291717837.2695.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Dec 2010 11:30:37 +0100

> Here is V2 of patch :
> 
> [PATCH v2 net-next-2.6] net: call dev_queue_xmit_nit() after skb_dst_drop()

Ahh, ok, I just noticed this.

I will make sure to apply this version instead.

Thanks!
