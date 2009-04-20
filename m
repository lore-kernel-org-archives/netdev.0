From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] tun: Fix sk_sleep races when attaching/detaching
Date: Mon, 20 Apr 2009 03:02:15 -0700 (PDT)
Message-ID: <20090420.030215.118567197.davem@davemloft.net>
References: <20090420083550.GA2582@gondor.apana.org.au>
	<20090420.022635.57839830.davem@davemloft.net>
	<20090420093549.GA3356@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, kaber@trash.net, zabaljauregui@gmail.com,
	odie@cs.aau.dk, rusty@rustcorp.com.au, lguest@ozlabs.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	borntraeger@de.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754304AbZDTKCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 06:02:24 -0400
In-Reply-To: <20090420093549.GA3356@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 20 Apr 2009 17:35:49 +0800

> On Mon, Apr 20, 2009 at 02:26:35AM -0700, David Miller wrote:
>> 
>> Do you think these two patches are ready to go into net-2.6
>> now?
> 
> I think so.

Great, applied, thanks Herbert.
