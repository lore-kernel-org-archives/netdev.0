From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reorganize IP MIB values
Date: Mon, 06 Aug 2012 13:41:03 -0700 (PDT)
Message-ID: <20120806.134103.492418140254658832.davem@davemloft.net>
References: <1344148439.9299.1570.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974Ab2HFUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:41:04 -0400
In-Reply-To: <1344148439.9299.1570.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Aug 2012 08:33:59 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Reduce IP latencies by placing hot MIB IP fields in a single cache line.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
