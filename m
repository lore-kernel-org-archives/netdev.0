From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: flow_dissector: add 802.1ad support
Date: Fri, 09 Aug 2013 11:06:45 -0700 (PDT)
Message-ID: <20130809.110645.539000252503299854.davem@davemloft.net>
References: <1375788906.4457.86.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965075Ab3HISGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:06:46 -0400
In-Reply-To: <1375788906.4457.86.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Aug 2013 04:35:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Same behavior than 802.1q : finds the encapsulated protocol and
> skip 32bit header.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
