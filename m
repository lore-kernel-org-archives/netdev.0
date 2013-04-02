From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Remove dead sysctl_tcp_cookie_size
 declaration
Date: Tue, 02 Apr 2013 14:25:38 -0400 (EDT)
Message-ID: <20130402.142538.1444331086180702402.davem@davemloft.net>
References: <1364922787-3756-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ycheng@google.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676Ab3DBSZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:25:41 -0400
In-Reply-To: <1364922787-3756-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue,  2 Apr 2013 13:13:07 -0400

> Remove a declaration left over from the TCPCT-ectomy. This sysctl is
> no longer referenced anywhere since 1a2c6181c4 ("tcp: Remove TCPCT").
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks Neal.
