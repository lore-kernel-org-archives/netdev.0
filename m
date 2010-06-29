From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/4] macvlan: 64 bit rx counters
Date: Mon, 28 Jun 2010 23:37:44 -0700 (PDT)
Message-ID: <20100628.233744.258117369.davem@davemloft.net>
References: <1277376861.2816.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363Ab0F2Ghb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:31 -0400
In-Reply-To: <1277376861.2816.284.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 12:54:21 +0200

> Use u64_stats_sync infrastructure to implement 64bit stats.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
