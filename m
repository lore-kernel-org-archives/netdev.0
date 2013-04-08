From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 08 Apr 2013 16:49:20 -0400 (EDT)
Message-ID: <20130408.164920.1647172260485548864.davem@davemloft.net>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
	<20130408082416.GW21448@secunet.com>
	<20130408093340.GA18594@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, jussi.kivilinna@iki.fi,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	tstdenis@elliptictech.com
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20130408093340.GA18594@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 8 Apr 2013 17:33:40 +0800

> On Mon, Apr 08, 2013 at 10:24:16AM +0200, Steffen Klassert wrote:
>> On Mon, Apr 08, 2013 at 10:48:44AM +0300, Jussi Kivilinna wrote:
>> > Patch adds support for NIST recommended block cipher mode CMAC to CryptoAPI.
>> > 
>> > This work is based on Tom St Denis' earlier patch,
>> >  http://marc.info/?l=linux-crypto-vger&m=135877306305466&w=2
>> > 
>> > Cc: Tom St Denis <tstdenis@elliptictech.com>
>> > Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
>> 
>> This patch does not apply clean to the ipsec-next tree
>> because of some crypto changes I don't have in ipsec-next.
>> The IPsec part should apply to the cryptodev tree,
>> so it's probaply the best if we route this patchset
>> through the cryptodev tree.
>> 
>> Herbert,
>> 
>> are you going to take these patches?
> 
> Sure I can do that.

I'm fine with this:

Acked-by: David S. Miller <davem@davemloft.net>
