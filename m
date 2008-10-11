From: David Miller <davem@davemloft.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 12:20:29 -0700 (PDT)
Message-ID: <20081011.122029.66617768.davem@davemloft.net>
References: <48EF7D24.6040400@trash.net>
	<20081011103935.GA6168@gondor.apana.org.au>
	<20081011124348.GA6845@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38703
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758706AbYJKTUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 15:20:53 -0400
In-Reply-To: <20081011124348.GA6845@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 11 Oct 2008 20:43:48 +0800

> gre: Initialise rtnl_link tunnel parameters properly
> 
> Brown paper bag error of calling memset with sizeof(p) instead
> of sizeof(*p).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6, thanks Herbert.
