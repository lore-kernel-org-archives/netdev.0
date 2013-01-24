From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Thu, 24 Jan 2013 08:00:08 -0500 (EST)
Message-ID: <148213573.113844.1359032408032.JavaMail.root@elliptictech.com>
References: <20130124125234.GL9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20130124125234.GL9147@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Steffen Klassert" <steffen.klassert@secunet.com>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
> linux-crypto@vger.kernel.org, "David Miller" <davem@davemloft.net>, "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
> Sent: Thursday, 24 January, 2013 7:52:34 AM
> Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent, and testmgr build issues
> 
> On Thu, Jan 24, 2013 at 07:37:50AM -0500, Tom St Denis wrote:
> > 
> > Also a question for the netdev folk, in order to be timely would it
> > be acceptable to patch ah4 and then ah6 with the AEAD changes?  Or
> > would the team require both to be patched simultaneously?
> >  
> 
> We would need patches for both, but the changes to ah4/ah6 should
> e very similar.

I suspect, I just don't know how my time table will look like so I was trying to not block the submission of one by the other.  Fortunately, I don't need hardware to test these changes so I can probably skunkwork them from home.

Tom
