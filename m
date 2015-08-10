From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [trivial] net: ethernet: Fix double word "the the" in
 eth.c
Date: Sun, 09 Aug 2015 22:53:12 -0700 (PDT)
Message-ID: <20150809.225312.226280437246354453.davem@davemloft.net>
References: <1438864074-3083-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, corbet@lwn.net
To: standby24x7@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbHJFxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 01:53:13 -0400
In-Reply-To: <1438864074-3083-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>
Date: Thu,  6 Aug 2015 21:27:54 +0900

> This patch fix double word "the the" in
> Documentation/DocBook/networking/API-eth-get-headlen.html
> Documentation/DocBook/networking/netdev.html
> Documentation/DocBook/networking.xml
> 
> These files are generated from comment in source,
> so I have to fix comment in net/ethernet/eth.c.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied to net-next, thanks.
