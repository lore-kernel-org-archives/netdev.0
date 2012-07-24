From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next V2] IB/ipoib: break linkage to
 neighbouring system
Date: Tue, 24 Jul 2012 14:00:15 -0700 (PDT)
Message-ID: <20120724.140015.1545062339709165330.davem@davemloft.net>
References: <1343150651-12568-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	cl@linux.com, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab2GXVAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:00:16 -0400
In-Reply-To: <1343150651-12568-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 24 Jul 2012 20:24:11 +0300

> Dave Miller <davem@davemloft.net> provided a detailed description of why the
> way IPoIB is using neighbours for its own ipoib_neigh struct is buggy:
 ...
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Acked-by: David S. Miller <davem@davemloft.net>

Looks good, Roland you got this?
