From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 06 Oct 2014 18:17:43 -0400 (EDT)
Message-ID: <20141006.181743.865615080283790796.davem@davemloft.net>
References: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbaJFWRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:17:44 -0400
In-Reply-To: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Oct 2014 11:26:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Marking this as static allows compiler to inline it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
