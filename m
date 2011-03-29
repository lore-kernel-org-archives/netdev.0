From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] xfrm: Move the test on replay window size into the
 replay check functions
Date: Mon, 28 Mar 2011 23:48:23 -0700 (PDT)
Message-ID: <20110328.234823.260087400.davem@davemloft.net>
References: <20110329054552.GI1290@secunet.com>
	<20110329062006.GA23079@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750774Ab1C2GtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 02:49:03 -0400
In-Reply-To: <20110329062006.GA23079@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 29 Mar 2011 14:20:06 +0800

> On Tue, Mar 29, 2011 at 07:45:52AM +0200, Steffen Klassert wrote:
>> As it is, the replay check is just performed if the replay window of the
>> legacy implementation is nonzero. So we move the test on a nonzero replay
>> window inside the replay check functions to be sure we are testing for the
>> right implementation.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> for all 4 patches.

All applied, thanks Steffen.
