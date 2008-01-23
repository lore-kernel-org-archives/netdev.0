From: David Miller <davem@davemloft.net>
Subject: Re: [INET]: Fix truesize setting in ip_append_data
Date: Tue, 22 Jan 2008 22:43:27 -0800 (PST)
Message-ID: <20080122.224327.149420034.davem@davemloft.net>
References: <20080123033942.GA698@gondor.apana.org.au>
	<20080122.214719.168781298.davem@davemloft.net>
	<20080123064131.GA2509@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753674AbYAWGnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:43:19 -0500
In-Reply-To: <20080123064131.GA2509@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 23 Jan 2008 17:41:31 +1100

> On Tue, Jan 22, 2008 at 09:47:19PM -0800, David Miller wrote:
> > 
> > I already checked in the ip_append_page() fix to net-2.6 so
> > I simply removed that hunk when adding your fix.
> > 
> > Thanks again!
> 
> Thank you!
> 
> I just received a message from Takahiro Yasui that my bug fix is buggy
> too :) So here is a fix on top of that.

I already correct this and respinned the net-2.6 tree
