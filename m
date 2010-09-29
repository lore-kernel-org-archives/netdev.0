From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next2.6] net: rename netdev rx_queue to
 ingress_queue
Date: Wed, 29 Sep 2010 13:27:39 -0700 (PDT)
Message-ID: <20100929.132739.35023082.davem@davemloft.net>
References: <1285689517.3154.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805Ab0I2U1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:27:19 -0400
In-Reply-To: <1285689517.3154.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 17:58:37 +0200

> There is some confusion with rx_queue name after RPS, and net drivers
> private rx_queue fields.
> 
> I suggest to rename "struct net_device"->rx_queue to ingress_queue.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
