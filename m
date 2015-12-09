From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: remove rx_pkt/rx_calls
Date: Tue, 08 Dec 2015 22:59:51 -0500 (EST)
Message-ID: <20151208.225951.1848968351614156276.davem@davemloft.net>
References: <1449599310.6639.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbbLID7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:59:52 -0500
In-Reply-To: <1449599310.6639.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Dec 2015 10:28:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> These fields are updated but never read.
> Remove the overhead.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
