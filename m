From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: clean up put_child
Date: Sun, 29 Jul 2012 23:19:20 -0700 (PDT)
Message-ID: <20120729.231920.2025065186040764256.davem@davemloft.net>
References: <1343563203.16365.1.camel@monkey32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab2G3GTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:19:21 -0400
In-Reply-To: <1343563203.16365.1.camel@monkey32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Sun, 29 Jul 2012 20:00:03 +0800

> The first parameter struct trie *t is not used anymore.
> Remove it.
> 
> Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>

Applied.
