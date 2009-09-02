From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Create buffer alloc and free helpers
Date: Tue, 01 Sep 2009 17:44:49 -0700 (PDT)
Message-ID: <20090901.174449.08076466.davem@davemloft.net>
References: <4A9D1FDF.4020407@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40479
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755454AbZIBAof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:44:35 -0400
In-Reply-To: <4A9D1FDF.4020407@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Tue, 01 Sep 2009 22:21:35 +0900

> Refactor similar two sections of code that free buffers into one.
> Only call tx_init if all buffer allocations succeed.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
