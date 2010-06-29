From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use this_cpu_ptr()
Date: Mon, 28 Jun 2010 23:37:30 -0700 (PDT)
Message-ID: <20100628.233730.200370863.davem@davemloft.net>
References: <1277376757.2816.272.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752332Ab0F2GhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:17 -0400
In-Reply-To: <1277376757.2816.272.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 12:52:37 +0200

> use this_cpu_ptr(p) instead of per_cpu_ptr(p, smp_processor_id())
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
