From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] r8169: add support for xmit_more
Date: Thu, 08 Jan 2015 19:51:14 -0800 (PST)
Message-ID: <20150108.195114.432473484324095623.davem@davemloft.net>
References: <1420624189-24325-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614AbbAIDpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:45:30 -0500
In-Reply-To: <1420624189-24325-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  7 Jan 2015 10:49:49 +0100

> Delay update of hw tail descriptor if we know that another skb is going
> to be sent.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
