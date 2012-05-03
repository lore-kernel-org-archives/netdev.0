From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Wed, 02 May 2012 20:32:18 -0400 (EDT)
Message-ID: <20120502.203218.1285569354339728768.davem@davemloft.net>
References: <1335988709.22133.632.camel@edumazet-glaptop>
	<1335989484.9611.11.camel@joe2Laptop>
	<1335990187.22133.636.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, alexander.duyck@gmail.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	mcarlson@broadcom.com, herbert@gondor.hengli.com.au,
	bhutchings@solarflare.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2ECAct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:32:49 -0400
In-Reply-To: <1335990187.22133.636.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 May 2012 22:23:07 +0200

> If a compiler or static checker complains, its only their problem.

It's also my problem, since it makes it even harder for me to see
any meaningful new warnings that crop up.
