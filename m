From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bridge: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 01:14:39 -0700 (PDT)
Message-ID: <20091029.011439.205370172.davem@davemloft.net>
References: <4AE864C7.3060100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51611
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752746AbZJ2IOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:14:15 -0400
In-Reply-To: <4AE864C7.3060100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 16:35:35 +0100

> Speedup module unloading by factorizing synchronize_rcu() calls
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
