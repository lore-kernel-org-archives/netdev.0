From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: net_families __rcu annotations
Date: Fri, 12 Nov 2010 13:27:48 -0800 (PST)
Message-ID: <20101112.132748.98878008.davem@davemloft.net>
References: <1289422244.17691.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755426Ab0KLV1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:27:24 -0500
In-Reply-To: <1289422244.17691.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Nov 2010 21:50:44 +0100

> Use modern RCU API / annotations for net_families array.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
