From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] de2104x: fix panic on load
Date: Wed, 03 Nov 2010 18:54:36 -0700 (PDT)
Message-ID: <20101103.185436.183037645.davem@davemloft.net>
References: <1288823132.2718.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754389Ab0KDByM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 21:54:12 -0400
In-Reply-To: <1288823132.2718.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Nov 2010 23:25:32 +0100

> Its now illegal to call netif_stop_queue() before register_netdev()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
