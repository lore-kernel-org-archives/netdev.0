From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: enable sockets to use MSG_FASTOPEN by
 default
Date: Mon, 04 Nov 2013 19:58:20 -0500 (EST)
Message-ID: <20131104.195820.571300845444915757.davem@davemloft.net>
References: <1383236372-1317-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	sivasankar@cs.ucsd.edu
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306Ab3KEA6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 19:58:22 -0500
In-Reply-To: <1383236372-1317-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 31 Oct 2013 09:19:32 -0700

> Applications have started to use Fast Open (e.g., Chrome browser has
> such an optional flag) and the feature has gone through several
> generations of kernels since 3.7 with many real network tests. It's
> time to enable this flag by default for applications to test more
> conveniently and extensively.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
