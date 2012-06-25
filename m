From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: struct sock cleanups
Date: Mon, 25 Jun 2012 16:09:28 -0700 (PDT)
Message-ID: <20120625.160928.1249284810299224774.davem@davemloft.net>
References: <1340605369.10893.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab2FYXJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:09:29 -0400
In-Reply-To: <1340605369.10893.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Jun 2012 08:22:49 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add missing kernel doc for sk_rx_dst
> 
> Move sk_rx_dst to avoid two 32bit holes on 64bit arches
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
