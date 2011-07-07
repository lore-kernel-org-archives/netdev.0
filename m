From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: use GFP_KERNEL allocations at device setup
Date: Thu, 07 Jul 2011 06:13:44 -0700 (PDT)
Message-ID: <20110707.061344.2082187945174803654.davem@davemloft.net>
References: <1310044288.2127.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560Ab1GGNNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 09:13:46 -0400
In-Reply-To: <1310044288.2127.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jul 2011 15:11:28 +0200

> In process and sleep allowed context, favor GFP_KERNEL allocations over
> GFP_ATOMIC ones.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
