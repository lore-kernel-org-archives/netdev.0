From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] ipv4: Delete routing cache.
Date: Mon, 02 Jul 2012 03:15:07 -0700 (PDT)
Message-ID: <20120702.031507.2093058758983732563.davem@davemloft.net>
References: <20120701.050249.1959437975207758368.davem@davemloft.net>
	<1341221712.5269.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932909Ab2GBKPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 06:15:18 -0400
In-Reply-To: <1341221712.5269.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jul 2012 11:35:12 +0200

> When testing this patch, I had to disable CONFIG_IP_ROUTE_VERBOSE to
> avoid a compile error at the end of ip_rt_redirect()

I'll try to get that fixed the next time I respin, thanks for the
report Eric.
