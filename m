From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make u64_stats_init() a function
Date: Mon, 15 Jun 2015 16:03:17 -0700 (PDT)
Message-ID: <20150615.160317.1711970020911499702.davem@davemloft.net>
References: <1434163488.27504.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbFOXDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:03:18 -0400
In-Reply-To: <1434163488.27504.122.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Jun 2015 19:44:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Using a function instead of a macro is cleaner and remove
> following W=1 warnings (extract)
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
