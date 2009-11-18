From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next-2.6] net: add dev_txq_stats_fold() helper
Date: Tue, 17 Nov 2009 23:52:50 -0800 (PST)
Message-ID: <20091117.235250.212250471.davem@davemloft.net>
References: <4B015573.9090502@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZKRHwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 02:52:33 -0500
In-Reply-To: <4B015573.9090502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Nov 2009 14:36:51 +0100

> Some drivers ndo_get_stats() method need to perform txqueue stats folding.
> 
> Move folding from dev_get_stats() to a new dev_txq_stats_fold() function
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
