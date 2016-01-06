From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] inet: kill unused skb_free op
Date: Tue, 05 Jan 2016 22:27:07 -0500 (EST)
Message-ID: <20160105.222707.384316051245980512.davem@davemloft.net>
References: <1452028675-30450-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbcAFD1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 22:27:12 -0500
In-Reply-To: <1452028675-30450-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  5 Jan 2016 22:17:55 +0100

> The only user was removed in commit
> 029f7f3b8701cc7a ("netfilter: ipv6: nf_defrag: avoid/free clone operations").
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Thanks for noticing this, applied, thanks Florian.
