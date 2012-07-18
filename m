From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 09:16:08 -0700 (PDT)
Message-ID: <20120718.091608.434505246378175004.davem@davemloft.net>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
	<1342619879.9551.14.camel@joe2Laptop>
	<1342620841.2626.2786.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, andrewmcgr@gmail.com,
	dave.taht@gmail.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab2GRQQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:16:09 -0400
In-Reply-To: <1342620841.2626.2786.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 16:14:01 +0200

> but hash_long() on 64bit sounds a bit expensive for our needs...

Agreed.
