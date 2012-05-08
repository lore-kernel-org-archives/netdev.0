From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherdev.h: Convert int is_<foo>_ether_addr to bool
Date: Tue, 08 May 2012 13:07:50 -0400 (EDT)
Message-ID: <20120508.130750.1101779801819696326.davem@davemloft.net>
References: <1336458936.29640.2.camel@joe2Laptop>
	<20120508.033120.1272130362698029549.davem@davemloft.net>
	<1336495480.29640.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328Ab2EHRI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 13:08:59 -0400
In-Reply-To: <1336495480.29640.19.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 08 May 2012 09:44:40 -0700

> Make the return value explicitly true or false.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good, applied, thanks Joe.
