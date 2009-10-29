From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipmr: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 01:14:33 -0700 (PDT)
Message-ID: <20091029.011433.245918166.davem@davemloft.net>
References: <4AE86182.80804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51608
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752703AbZJ2IOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:14:09 -0400
In-Reply-To: <4AE86182.80804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 16:21:38 +0100

> Speedup module unloading by factorizing synchronize_rcu() calls
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
