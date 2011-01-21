From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: sit: fix rcu annotations
Date: Thu, 20 Jan 2011 16:56:48 -0800 (PST)
Message-ID: <20110120.165648.172535385.davem@davemloft.net>
References: <1295543784.2825.409.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754916Ab1AUA4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:56:14 -0500
In-Reply-To: <1295543784.2825.409.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jan 2011 18:16:24 +0100

> Fix minor __rcu annotations and remove sparse warnings
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
