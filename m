From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next]atl11:set MAX_TX_OFFLOAD_THRESH to 6k from 9k
 and fix spelling error
Date: Mon, 03 Aug 2009 13:21:30 -0700 (PDT)
Message-ID: <20090803.132130.43462719.davem@davemloft.net>
References: <1249278232896-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbZHCUVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 16:21:21 -0400
In-Reply-To: <1249278232896-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Mon, 3 Aug 2009 13:43:52 +0800

> 1. Set MAX_TX_OFFLOAD_THRESH to 6k from 9k, when mtu large then MAX_TX_OFFLOAD_THRESH
>    just disable NETIF_F_TSO6, NETIF_F_TSO, NETIF_F_HW_CSUM.
> 
> 2. Fix spelling error, change REG_TWSI_CTRL to REG_TXQ_CTRL.
> 
> Signed-off-by: jie yang <jie.yang>@atheros.com

Please repost these two patches with your signoff fixed.

Thanks.
