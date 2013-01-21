From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] ADDRCONF/NDISC improvements
Date: Sun, 20 Jan 2013 22:30:03 -0500 (EST)
Message-ID: <20130120.223003.279991641417974881.davem@davemloft.net>
References: <50FC2B97.7020601@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab3AUDaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 22:30:07 -0500
In-Reply-To: <50FC2B97.7020601@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 21 Jan 2013 02:38:31 +0900

> These are for address comparison improvements and boolean conversion.
> 
> YOSHIFUJI Hideaki (5):
>   ipv6: Make ipv6_addr_is_XXX() return boolean.
>   ipv6: Introduce ipv6_addr_is_solict_mult() to check Solicited Node
>     Multicast Addresses.
>   ipv6: Optimize ipv6_addr_is_solict_mult().
>   ipv6: Optimize ipv6_addr_is_ll_all_{nodes,routers}().
>   ndisc: Make several arguments for ndisc_send_na() boolean.

All applied, thanks.
