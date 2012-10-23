From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: clean up tcp_v4_early_demux()
Date: Tue, 23 Oct 2012 13:04:08 -0400 (EDT)
Message-ID: <20121023.130408.2281842419818319443.davem@davemloft.net>
References: <1350978167.8609.1545.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243Ab2JWREJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:04:09 -0400
In-Reply-To: <1350978167.8609.1545.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Oct 2012 09:42:47 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Use same header helpers than tcp_v6_early_demux() because they
> are a bit faster, and as they make IPv4/IPv6 versions look
> the same.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
