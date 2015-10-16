From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] tcp/dccp: make our listener code more
 robust
Date: Fri, 16 Oct 2015 01:02:25 -0700 (PDT)
Message-ID: <20151016.010225.1717271460323068706.davem@davemloft.net>
References: <1444846588-28344-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbJPHqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:46:16 -0400
In-Reply-To: <1444846588-28344-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 14 Oct 2015 11:16:25 -0700

> This patch series addresses request sockets leaks and listener dismantle
> phase. This survives a stress test with listeners being added/removed
> quite randomly.

Series applied, thanks Eric.
