From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: remove obsolete md5_add() method
Date: Tue, 31 Jan 2012 12:14:11 -0500 (EST)
Message-ID: <20120131.121411.1917911339959901911.davem@davemloft.net>
References: <1328007882.2297.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989Ab2AaROS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:14:18 -0500
In-Reply-To: <1328007882.2297.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 12:04:42 +0100

> We no longer use md5_add() method from struct tcp_sock_af_ops
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
