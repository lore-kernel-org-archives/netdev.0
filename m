From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] route: Remove redirect_genid
Date: Thu, 08 Mar 2012 00:31:19 -0800 (PST)
Message-ID: <20120308.003119.729862333135345198.davem@davemloft.net>
References: <20120307071940.GF15404@secunet.com>
	<20120307072110.GH15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231Ab2CHIbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:31:34 -0500
In-Reply-To: <20120307072110.GH15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 7 Mar 2012 08:21:10 +0100

> As we invalidate the inetpeer tree along with the routing cache now,
> we don't need a genid to reset the redirect handling when the routing
> cache is flushed.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
