From: David Miller <davem@davemloft.net>
Subject: Re: [PATCN net-next-2.6] drivers/net: use vzalloc()
Date: Sat, 27 Nov 2010 22:54:01 -0800 (PST)
Message-ID: <20101127.225401.183027498.davem@davemloft.net>
References: <1290420906.2811.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751427Ab0K1Gxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 01:53:35 -0500
In-Reply-To: <1290420906.2811.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Nov 2010 11:15:06 +0100

> Use vzalloc() and vzalloc_node() in net drivers
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
