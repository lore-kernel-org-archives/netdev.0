From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: poll() optimizations
Date: Mon, 06 Sep 2010 18:40:49 -0700 (PDT)
Message-ID: <20100906.184049.57452139.davem@davemloft.net>
References: <1283807630.2585.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756034Ab0IGBkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:40:31 -0400
In-Reply-To: <1283807630.2585.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Sep 2010 23:13:50 +0200

> No need to test twice sk->sk_shutdown & RCV_SHUTDOWN
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
