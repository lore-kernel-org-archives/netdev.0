From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Thu, 03 May 2012 02:28:37 -0400 (EDT)
Message-ID: <20120503.022837.2021054007853235758.davem@davemloft.net>
References: <1335765093.2296.4.camel@edumazet-glaptop>
	<20120502055018.GA50959@tuxmaker.boeblingen.de.ibm.com>
	<1335941961.22133.48.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org, arnd@arndb.de,
	linux-s390@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab2ECG2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 02:28:45 -0400
In-Reply-To: <1335941961.22133.48.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 May 2012 08:59:21 +0200

> If Arnd doesnt care to even reply, we can just revert his buggy
> patch, instead of trying to understand and fix all issues.

Agreed, it's the best sounding solution by far.
