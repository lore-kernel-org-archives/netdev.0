From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Mon, 01 Oct 2012 17:04:17 -0400 (EDT)
Message-ID: <20121001.170417.375196441753231353.davem@davemloft.net>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab2JAVES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:04:18 -0400
In-Reply-To: <1348750130.5093.1227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Sep 2012 14:48:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add GRO capability to IPv4 GRE tunnels, using the gro_cells
> infrastructure.
> 
> Tested using IPv4 and IPv6 TCP traffic inside this tunnel, and
> checking GRO is building large packets.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
