From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 22:02:53 -0400 (EDT)
Message-ID: <20131029.220253.1263087684709722001.davem@davemloft.net>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.194446.2215574000648693370.davem@davemloft.net>
	<1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab3J3CCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:02:55 -0400
In-Reply-To: <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Oct 2013 17:53:48 -0700

> So should we apply the first fix to avoid the BUG_ON() ?

Please be more specific, are you talking about splitting up
this patch in some way?
