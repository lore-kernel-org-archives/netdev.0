From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio: net: remove sparse errors
Date: Mon, 13 Feb 2012 15:58:44 -0500 (EST)
Message-ID: <20120213.155844.1402728313889281249.davem@davemloft.net>
References: <1329152021.2494.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	rusty@rustcorp.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971Ab2BMU6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 15:58:51 -0500
In-Reply-To: <1329152021.2494.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Feb 2012 17:53:41 +0100

> commit 3fa2a1df909 (virtio-net: per cpu 64 bit stats (v2)) added extra
> __percpu qualifiers and sparse errors.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
