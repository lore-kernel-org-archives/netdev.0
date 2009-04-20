From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] tun: Fix sk_sleep races when attaching/detaching
Date: Mon, 20 Apr 2009 02:26:35 -0700 (PDT)
Message-ID: <20090420.022635.57839830.davem@davemloft.net>
References: <20090416110818.GA20950@gondor.apana.org.au>
	<20090416110952.GB20950@gondor.apana.org.au>
	<20090420083550.GA2582@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, kaber@trash.net, zabaljauregui@gmail.com,
	odie@cs.aau.dk, rusty@rustcorp.com.au, lguest@ozlabs.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	borntraeger@de.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56690
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750922AbZDTJ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:26:43 -0400
In-Reply-To: <20090420083550.GA2582@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 20 Apr 2009 16:35:50 +0800

> On Thu, Apr 16, 2009 at 07:09:52PM +0800, Herbert Xu wrote:
>> 
>> tun: Fix sk_sleep races when attaching/detaching
> 
> That patch doesn't apply anymore because of contextual changes
> caused by the first patch.  Here's an update.
> 
> tun: Fix sk_sleep races when attaching/detaching

Do you think these two patches are ready to go into net-2.6
now?

Thanks.
