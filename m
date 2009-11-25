From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Add SHA384 and SHA512 HMAC authentication
 algorithms to XFRM
Date: Wed, 25 Nov 2009 15:49:02 -0800 (PST)
Message-ID: <20091125.154902.139476687.davem@davemloft.net>
References: <1259146719-16359-1-git-send-email-martin@strongswan.org>
	<20091125121140.GB28385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@strongswan.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964994AbZKYXso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:48:44 -0500
In-Reply-To: <20091125121140.GB28385@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 25 Nov 2009 20:11:40 +0800

> On Wed, Nov 25, 2009 at 11:58:39AM +0100, Martin Willi wrote:
>> These algorithms use a truncation of 192/256 bits, as specified
>> in RFC4868.
>> 
>> Signed-off-by: Martin Willi <martin@strongswan.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6
