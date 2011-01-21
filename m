From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: raw: rcu annotations
Date: Thu, 20 Jan 2011 16:56:55 -0800 (PST)
Message-ID: <20110120.165655.45152979.davem@davemloft.net>
References: <1295545073.2825.436.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755096Ab1AUA4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:56:20 -0500
In-Reply-To: <1295545073.2825.436.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jan 2011 18:37:53 +0100

> Remove sparse warnings, using a function typedef to be able to use __rcu
> annotation on mh_filter pointer.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
