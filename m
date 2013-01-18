From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Fri, 18 Jan 2013 14:35:33 -0500 (EST)
Message-ID: <396283550.90353.1358537733820.JavaMail.root@elliptictech.com>
References: <20130116062104.GA18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116062104.GA18940@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any "maintainers" going to reply to this at all?  

Tom

----- Original Message -----
> From: "Steffen Klassert" <steffen.klassert@secunet.com>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: herbert@gondor.apana.org.au, davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Wednesday, 16 January, 2013 1:21:04 AM
> Subject: Re: IPsec AH use of ahash
> 
> Please Cc netdev@vger.kernel.org on all networking related topics.
> 
> On Tue, Jan 15, 2013 at 11:51:48AM -0500, Tom St Denis wrote:
> > Hi all,
> > 
> > The AH4/6 code uses ahash to perform the MAC calculation but this
> > precludes the availability of GMAC to the user.  Are there any
> > plans to port the AH code over to the aead API so that it can use
> > potentially any algo available to the user?
> > 
> 
> There was no need for this by now, but you are welcome
> to send patches.
> 
