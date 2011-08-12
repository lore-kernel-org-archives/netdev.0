From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] be2net: fixes
Date: Fri, 12 Aug 2011 02:56:59 -0700 (PDT)
Message-ID: <20110812.025659.1243555545035014735.davem@davemloft.net>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
	<1312904848.2371.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1312906987.2371.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab1HLJ5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 05:57:05 -0400
In-Reply-To: <1312906987.2371.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Aug 2011 18:23:07 +0200

> [PATCH] benet: fix build error on 32bit arch
> 
> Error comes from commit ac124ff973e27802797
> (be2net: cleanup and refactor stats code)
> 
> ERROR: "__udivdi3" [drivers/net/benet/be2net.ko] undefined!
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Sathya Perla <sathya.perla@emulex.com>

Applied.
