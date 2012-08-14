From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fib_trie: Don't unnecessarily search for
 already found fib leaf
Date: Tue, 14 Aug 2012 15:02:37 -0700 (PDT)
Message-ID: <20120814.150237.1379945241477414075.davem@davemloft.net>
References: <igorm@etf.rs>
	<1344846368-4141-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab2HNWCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 18:02:38 -0400
In-Reply-To: <1344846368-4141-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: igorm@etf.rs
Date: Mon, 13 Aug 2012 10:26:08 +0200

> From: Igor Maravic <igorm@etf.rs>
> 
> We've already found leaf, don't search for it again. Same is for fib leaf info.
> 
> Signed-off-by: Igor Maravic <igorm@etf.rs>

Applied to net-next, thanks.
