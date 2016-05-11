From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix 4in6 tunnel receive path
Date: Wed, 11 May 2016 19:24:20 -0400 (EDT)
Message-ID: <20160511.192420.2022658589383090611.davem@davemloft.net>
References: <1462889297-12953-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbcEKXYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:24:22 -0400
In-Reply-To: <1462889297-12953-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 10 May 2016 16:08:17 +0200

> Protocol for 4in6 tunnel is IPPROTO_IPIP. This was wrongly changed by
> the last cleanup.
> 
> CC: Tom Herbert <tom@herbertland.com>
> Fixes: 0d3c703a9d17 ("ipv6: Cleanup IPv6 tunnel receive path")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
