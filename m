From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 09 Dec 2012 00:46:56 -0500 (EST)
Message-ID: <20121209.004656.468043362420071590.davem@davemloft.net>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468Ab2LIFq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:46:57 -0500
In-Reply-To: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks a lot for working on a complete fix for these problems, I'll
review these patches soon.
