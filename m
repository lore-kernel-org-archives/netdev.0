From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: Simplify the replay check and advance
 functions
Date: Tue, 18 Oct 2011 23:51:47 -0400 (EDT)
Message-ID: <20111018.235147.329530506305628010.davem@davemloft.net>
References: <20111011115837.GK1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab1JSDwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:52:04 -0400
In-Reply-To: <20111011115837.GK1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 13:58:37 +0200

> The replay check and replay advance functions had some code
> duplications. This patch removes the duplications.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
