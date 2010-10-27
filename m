From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_rules: __rcu annotates ctarget
Date: Wed, 27 Oct 2010 11:22:51 -0700 (PDT)
Message-ID: <20101027.112251.229754964.davem@davemloft.net>
References: <1288121095.2652.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754821Ab0J0SW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:22:27 -0400
In-Reply-To: <1288121095.2652.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 21:24:55 +0200

> Adds __rcu annotation to (struct fib_rule)->ctarget
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
