From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix debug info in tnode_new
Date: Sun, 29 Jul 2012 23:19:12 -0700 (PDT)
Message-ID: <20120729.231912.2256527642514992781.davem@davemloft.net>
References: <1343560795.5975.1.camel@monkey32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2G3GTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:19:13 -0400
In-Reply-To: <1343560795.5975.1.camel@monkey32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Sun, 29 Jul 2012 19:19:55 +0800

> It should print size of struct rt_trie_node * allocated instead of size
> of struct rt_trie_node.
> 
> Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>

Applied.
