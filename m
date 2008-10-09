From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] gre: Ethernet over GRE
Date: Thu, 09 Oct 2008 12:01:05 -0700 (PDT)
Message-ID: <20081009.120105.134867835.davem@davemloft.net>
References: <20081009070424.GA16684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760516AbYJITB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:01:29 -0400
In-Reply-To: <20081009070424.GA16684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 9 Oct 2008 15:04:24 +0800

> This series of patches add Ethernet over GRE support.  The user
> space interface is done with the rtnl_link mechanism.  I'll post
> the patches for iproute too.

Nice.

All applied, and I made sure to use the updated version of
patch 4.

Thanks!
