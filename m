From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/sh-eth: Add support selecting MII function for
 SH7734 and R8A7740
Date: Tue, 12 Jun 2012 00:29:54 -0700 (PDT)
Message-ID: <20120612.002954.1384327664115800772.davem@davemloft.net>
References: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab2FLH35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 03:29:57 -0400
In-Reply-To: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Tue, 12 Jun 2012 16:29:02 +0900

> @@ -492,6 +513,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>  	.no_trimd	= 1,
>  	.no_ade		= 1,
>  	.tsu		= 1,
> +	.select_mii = 1,
>  };
>  

Indent this new line consistently with those around it.
