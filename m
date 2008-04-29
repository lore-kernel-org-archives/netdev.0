From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Wed, 30 Apr 2008 00:57:56 +0400
Message-ID: <20080429205756.GA30032@2ka.mipt.ru>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au> <4816AD93.5090404@trash.net> <20080429135932.GA20790@gondor.apana.org.au> <20080429142144.GB16068@2ka.mipt.ru> <20080429144503.GA21238@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080429144503.GA21238@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2008 at 10:45:03PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Tue, Apr 29, 2008 at 06:21:44PM +0400, Evgeniy Polyakov wrote:
> > 
> > Hey, it works :))
> > Just not always, which is great at attracting Patrick and problems.
> 
> I was more commenting on the bugs in the crypto layer that breaks
> hifn rather than the hifn driver itself :)

I was just kidding of course :)

Actually this is great that even obscure problems got fixed because of
some other problems in seems to be unrelated areas.

-- 
	Evgeniy Polyakov
