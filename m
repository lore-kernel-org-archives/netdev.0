From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ipv6: ip6_ptr rcu annotations
Date: Mon, 25 Oct 2010 13:10:41 -0700 (PDT)
Message-ID: <20101025.131041.245411072.davem@davemloft.net>
References: <1287991925.2658.5380.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757874Ab0JYUKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:10:18 -0400
In-Reply-To: <1287991925.2658.5380.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 09:32:05 +0200

> (struct net_device)->ip6_ptr is rcu protected :
> 
> add __rcu annotation and proper rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
