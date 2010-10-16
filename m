From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib6: use FIB_LOOKUP_NOREF in
 fib6_rule_lookup()
Date: Sat, 16 Oct 2010 11:55:42 -0700 (PDT)
Message-ID: <20101016.115542.39162471.davem@davemloft.net>
References: <1286973940.3876.423.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:20 -0400
In-Reply-To: <1286973940.3876.423.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Oct 2010 14:45:40 +0200

> Avoid two atomic ops on found rule in fib6_rule_lookup()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
