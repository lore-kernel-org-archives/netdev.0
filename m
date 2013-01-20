From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 08:54:24 -0500 (EST)
Message-ID: <650108746.93086.1358690064783.JavaMail.root@elliptictech.com>
References: <50FBF25C.4030604@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Borislav Petkov <bp@alien8.de>, Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	Mike Galbraith <bitbucket@online.de>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FBF25C.4030604@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Alexander Holler" <holler@ahsoftware.de>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Borislav Petkov" <bp@alien8.de>, "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter P"
> <peter.p.waskiewicz.jr@intel.com>, "David Miller" <davem@davemloft.net>, "steffen klassert"
> <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
> "Michal Kubecek" <mkubecek@suse.cz>, "Mike Galbraith" <bitbucket@online.de>
> Sent: Sunday, 20 January, 2013 8:34:20 AM
> Subject: Re: IPsec AH use of ahash
> 
> Am 20.01.2013 13:56, schrieb Tom St Denis:
> 
> > You should really try running checkpatch.pl over code that's
> > already in the kernel before you call out new contributors on it.
> >
> > How is this supposed to not be adversarial when I can't even use
> > the Kernel source itself as a reference?
> 
> In case of the kernel the chicken and egg problem can be answered
> without any questions, most source existed before checkpatch.pl
> (evolved
> to the current state).

We clearly have different interpretations of the word "maintainer" then...  If they're not maintaining the code then are they really the maintainers of it?

Point is I copied accepted kernel code and was rejected because of "errors" that are in existing kernel code.  Similarly if I did the upgrade to AH to use AEAD I suspect it would be rejected for the same reason.

Tom
