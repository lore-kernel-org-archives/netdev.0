From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] sfc: Use ether_addr_copy and
 eth_broadcast_addr
Date: Mon, 10 Mar 2014 13:53:51 -0400 (EDT)
Message-ID: <20140310.135351.2126160196807825851.davem@davemloft.net>
References: <alpine.LFD.2.03.1403071759510.11827@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sshah@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbaCJRxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:53:54 -0400
In-Reply-To: <alpine.LFD.2.03.1403071759510.11827@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 7 Mar 2014 18:27:41 +0000

> Faster than memcpy/memset on some architectures.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> v2: fixed indentation

This looks fine, applied, thanks.
