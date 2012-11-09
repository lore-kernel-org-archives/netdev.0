From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: remove redundant replay_esn check
Date: Thu, 08 Nov 2012 22:00:20 -0500 (EST)
Message-ID: <20121108.220020.884271049343560692.davem@davemloft.net>
References: <20121108101544.GA30309@uweber-WS>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: ulrich.weber@sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964Ab2KIDAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 22:00:24 -0500
In-Reply-To: <20121108101544.GA30309@uweber-WS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@sophos.com>
Date: Thu, 8 Nov 2012 11:15:44 +0100

> x->replay_esn is already checked in if clause,
> so remove check and ident properly
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

Steffen, I assume you'll pick this one up.
