From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec AH use of ahash
Date: Wed, 16 Jan 2013 07:21:04 +0100
Message-ID: <20130116062104.GA18940@secunet.com>
References: <528051367.70594.1358268708738.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <528051367.70594.1358268708738.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please Cc netdev@vger.kernel.org on all networking related topics.

On Tue, Jan 15, 2013 at 11:51:48AM -0500, Tom St Denis wrote:
> Hi all,
> 
> The AH4/6 code uses ahash to perform the MAC calculation but this precludes the availability of GMAC to the user.  Are there any plans to port the AH code over to the aead API so that it can use potentially any algo available to the user?
> 

There was no need for this by now, but you are welcome
to send patches.
