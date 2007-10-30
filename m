From: David Miller <davem@davemloft.net>
Subject: Re: [0/11] Merge bundle creation and other misc fixes/clean-ups
Date: Mon, 29 Oct 2007 22:06:35 -0700 (PDT)
Message-ID: <20071029.220635.262385821.davem@davemloft.net>
References: <20071023160217.GA32102@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36268
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752936AbXJ3FGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 01:06:34 -0400
In-Reply-To: <20071023160217.GA32102@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Oct 2007 00:02:17 +0800

> This series of patches fixes the bug where the bundle creation
> code treats IPv6 routes as IPv4 or vice versa.
> 
> I think this is suitable for 2.6.25.
> 
> They do fix bugs but I don't think any of them are serious enough
> for inclusion in 2.6.24.

I did a review of these patches and these look fine.

Please resubmit this and the 3-patch input interfamily
fix set when I open up the net-2.6.25 tree.

I'll probably open up net-2.6.25 approximately one week
from now.
