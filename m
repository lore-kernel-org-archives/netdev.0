From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] net: add and use skb_gso_transport_seglen()
Date: Sun, 26 Jan 2014 22:41:37 -0800 (PST)
Message-ID: <20140126.224137.189578820909857783.davem@davemloft.net>
References: <1390730297-10725-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaA0Gll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:41:41 -0500
In-Reply-To: <1390730297-10725-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 26 Jan 2014 10:58:16 +0100

> This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
> skbuff core so it may be reused by upcoming ip forwarding path patch.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
