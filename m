From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Sun, 18 Jan 2009 21:47:29 -0800 (PST)
Message-ID: <20090118.214729.257523668.davem@davemloft.net>
References: <20090113092625.GA28015@gondor.apana.org.au>
	<20090113092828.GA28052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbZASFr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:47:27 -0500
In-Reply-To: <20090113092828.GA28052@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Jan 2009 20:28:28 +1100

> igb: Replace LRO with GRO
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Have the crashes reported by Intel been sorted out yet?
If so, I'll queue this up for 2.6.30

Otherwise please resubmit once the problem is resolved.

Thanks.
