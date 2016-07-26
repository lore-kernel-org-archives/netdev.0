From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: Scrub skb before crossing the namespace
 boundry
Date: Mon, 25 Jul 2016 21:48:47 -0700 (PDT)
Message-ID: <20160725.214847.185245089974986608.davem@davemloft.net>
References: <1469482696-32271-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcGZEst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 00:48:49 -0400
In-Reply-To: <1469482696-32271-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Mon, 25 Jul 2016 14:38:16 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The earlier patch c3aaa06d5a63 (ipvlan: scrub skb before routing
> in L3 mode.) did this but only for TX path in L3 mode. This
> patch extends it for both the modes for TX/RX path.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
