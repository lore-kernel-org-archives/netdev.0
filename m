From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cls_flow: remove one dynamic array
Date: Wed, 14 Dec 2011 13:35:13 -0500 (EST)
Message-ID: <20111214.133513.1274110771384025968.davem@davemloft.net>
References: <1323865800.2334.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab1LNSfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 13:35:18 -0500
In-Reply-To: <1323865800.2334.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Dec 2011 13:30:00 +0100

> Its better to use a predefined size for this small automatic variable.
> 
> Removes a sparse error as well :
> 
> net/sched/cls_flow.c:288:13: error: bad constant expression
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
