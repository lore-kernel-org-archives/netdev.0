From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 18:21:44 +0400
Message-ID: <20080429142144.GB16068@2ka.mipt.ru>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au> <4816AD93.5090404@trash.net> <20080429135932.GA20790@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080429135932.GA20790@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2008 at 09:59:32PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> It's a good thing the hifn driver doesn't work yet :)

Hey, it works :))
Just not always, which is great at attracting Patrick and problems.

-- 
	Evgeniy Polyakov
