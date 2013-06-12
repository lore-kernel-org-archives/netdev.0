From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: fix two sparse errors
Date: Wed, 12 Jun 2013 15:03:58 -0700 (PDT)
Message-ID: <20130612.150358.356411495562102033.davem@davemloft.net>
References: <1371072699.3252.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758106Ab3FLWEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:04:00 -0400
In-Reply-To: <1371072699.3252.73.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Jun 2013 14:31:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit ba418fa357a7b3c ("soreuseport: UDP/IPv4 implementation")
> added following sparse errors :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
