From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Add an error handler for icmp6
Date: Fri, 18 Jan 2013 14:20:17 -0500 (EST)
Message-ID: <20130118.142017.1798763703843518227.davem@davemloft.net>
References: <20130117080949.GA24987@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djduanjiong@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab3ARTUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:20:18 -0500
In-Reply-To: <20130117080949.GA24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 17 Jan 2013 09:09:49 +0100

> pmtu and redirect events are now handled in the protocols error handler,
> so add an error handler for icmp6 to do this. It is needed in the case
> when we have no socket context. Based on a patch by Duan Jiong.
> 
> Reported-by: Duan Jiong <djduanjiong@gmail.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable, thanks Steffen.
