From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] SCHED: netem: Correct documentation comment in
 code.
Date: Mon, 15 Dec 2008 00:39:24 -0800 (PST)
Message-ID: <20081215.003924.157494690.davem@davemloft.net>
References: <1229001489.18280.179.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752125AbYLOIjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 03:39:23 -0500
In-Reply-To: <1229001489.18280.179.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Thu, 11 Dec 2008 14:18:09 +0100

> 
> The netem simulator is no longer limited by Linux timer resolution HZ.
> Not since Patrick McHardy changed the QoS system to use hrtimer.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Applied, thanks Jesper.
