From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 09:19:28 -0700 (PDT)
Message-ID: <20120718.091928.492512069081953171.davem@davemloft.net>
References: <1342620841.2626.2786.camel@edumazet-glaptop>
	<1342621670.2626.2818.camel@edumazet-glaptop>
	<20120718.091647.2208692760443941786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, andrewmcgr@gmail.com,
	dave.taht@gmail.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562Ab2GRQTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:19:30 -0400
In-Reply-To: <20120718.091647.2208692760443941786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 18 Jul 2012 09:16:47 -0700 (PDT)

> 
> Just to clarify, I made sure to use this version.

Did you actually try to compile this?

net/ipv6/addrconf.c already has a function named ipv6_addr_hash()
and you didn't remove it in your patch.
