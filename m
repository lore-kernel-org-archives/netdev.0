From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: add and use skb_gso_transport_seglen()
Date: Mon, 27 Jan 2014 00:30:48 -0800 (PST)
Message-ID: <20140127.003048.1022038891323342746.davem@davemloft.net>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbaA0Iau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 03:30:50 -0500
In-Reply-To: <1390810971-23959-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 27 Jan 2014 09:22:50 +0100

> This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
> skbuff core so it may be reused by upcoming ip forwarding path patch.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  No changes since V2, resending since patch 2/2 had issues
>  and I don't see 1/2 in net tree.

Sorry, I forgot to push after my test builds, done.
