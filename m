From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net/irda: sh_sir: tidyup compile warning
Date: Thu, 11 Aug 2011 05:54:02 -0700 (PDT)
Message-ID: <20110811.055402.1398178965872838288.davem@davemloft.net>
References: <20110810.231558.2202030270747790994.davem@davemloft.net>
	<877h6kwbiq.wl%kuninori.morimoto.gx@renesas.com>
	<8739h8wb79.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuninori.morimoto.gx@renesas.com, netdev@vger.kernel.org
To: kuninori.morimoto.gx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab1HKMyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:54:07 -0400
In-Reply-To: <8739h8wb79.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kuninori.morimoto.gx@gmail.com
Date: Thu, 11 Aug 2011 02:26:37 -0700 (PDT)

> From: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
> 
> This patch tidyup below warning
> 
> ${LINUX}/drivers/net/irda/sh_sir.c:514:6: warning:
>  'val' may be used uninitialized in this function
> 
> Signed-off-by: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>

Applied.
