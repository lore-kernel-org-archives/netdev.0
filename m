From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check net.core.somaxconn sysctl values
Date: Wed, 31 Jul 2013 17:10:19 -0700 (PDT)
Message-ID: <20130731.171019.1991802407661623893.davem@davemloft.net>
References: <51F917CF.7010905@yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, raise.sail@gmail.com,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: klamm@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab3HAAKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:10:21 -0400
In-Reply-To: <51F917CF.7010905@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Gushchin <klamm@yandex-team.ru>
Date: Wed, 31 Jul 2013 17:57:35 +0400

> ---
>  net/core/sysctl_net_core.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index cfdb46a..2ff093b 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -20,7 +20,9 @@

This patch is against old sources, please respin it against the current
tree.

Thanks.
