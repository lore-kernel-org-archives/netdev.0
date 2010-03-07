From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bridge: cleanup: remove unneed check
Date: Sun, 07 Mar 2010 15:27:57 -0800 (PST)
Message-ID: <20100307.152757.142897943.davem@davemloft.net>
References: <20100306111408.GJ4958@bicker>
	<20100306122031.GA15864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751063Ab0CGX1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:27:37 -0500
In-Reply-To: <20100306122031.GA15864@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 6 Mar 2010 20:20:32 +0800

> On Sat, Mar 06, 2010 at 02:14:09PM +0300, Dan Carpenter wrote:
>> We dereference "port" on the lines immediately before and immediately 
>> after the test so port should hopefully never be null here.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Yes this looks correct to me.

Applied.
