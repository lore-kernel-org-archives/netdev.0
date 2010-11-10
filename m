From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Wed, 10 Nov 2010 13:00:40 -0800 (PST)
Message-ID: <20101110.130040.70204542.davem@davemloft.net>
References: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
	<1289385696.2860.147.camel@edumazet-laptop>
	<AANLkTi=5rxQ6mmnhR7=_dh5u08raaoLiYo=6Gzj9CbL5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756142Ab0KJVAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:00:15 -0500
In-Reply-To: <AANLkTi=5rxQ6mmnhR7=_dh5u08raaoLiYo=6Gzj9CbL5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 10 Nov 2010 08:27:54 -0800

> Also I noticed that the comment about RX queues refcnts is no longer
> valid.  I can respin patch if necessary.

Not necessary, when I apply your patch I'll integrate this comment
removal.

Thanks.
