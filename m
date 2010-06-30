From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/core: use ntohs for skb->protocol
Date: Wed, 30 Jun 2010 10:39:29 -0700 (PDT)
Message-ID: <20100630.103929.73674274.davem@davemloft.net>
References: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
	<20100629.151740.135534374.davem@davemloft.net>
	<20100630090229.GB25541@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0F3RjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:39:15 -0400
In-Reply-To: <20100630090229.GB25541@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Wed, 30 Jun 2010 11:02:29 +0200

> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> This is only noticed by people that are not doing everything correct in
> the first place.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied to net-next-2.6, thanks.
