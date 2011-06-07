From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove interrupt.h inclusion from
 netdevice.h
Date: Mon, 06 Jun 2011 22:55:37 -0700 (PDT)
Message-ID: <20110606.225537.2252563107857769792.davem@davemloft.net>
References: <20110606204346.GA24175@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab1FGFzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:55:40 -0400
In-Reply-To: <20110606204346.GA24175@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 6 Jun 2011 23:43:46 +0300

> * remove interrupt.g inclusion from netdevice.h -- not needed
> * fixup fallout, add interrupt.h and hardirq.h back where needed.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Thanks for doing this, patch applied.
