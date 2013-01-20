From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 07:56:27 -0500 (EST)
Message-ID: <313650836.93071.1358686587647.JavaMail.root@elliptictech.com>
References: <20130120103132.GA16800@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	Mike Galbraith <bitbucket@online.de>
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130120103132.GA16800@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Borislav Petkov" <bp@alien8.de>
> To: "Mike Galbraith" <bitbucket@online.de>
> Cc: "Tom St Denis" <tstdenis@elliptictech.com>, "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter P"
> <peter.p.waskiewicz.jr@intel.com>, "David Miller" <davem@davemloft.net>, "steffen klassert"
> <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
> "Michal Kubecek" <mkubecek@suse.cz>
> Sent: Sunday, 20 January, 2013 5:31:32 AM
> Subject: Re: IPsec AH use of ahash
> 
> On Sun, Jan 20, 2013 at 06:06:21AM +0100, Mike Galbraith wrote:
> > Sounds as though any patches you submit land on your dinner plate
> > just
> > like potatoes. Hand the cook a pot of half peeled potatoes, he/she
> > may
> > say try again.
> 
> And how he/she would say it! I've seen serious fights spring up from
> half-peeled potatoes so people better peel them right the first time.

You should really try running checkpatch.pl over code that's already in the kernel before you call out new contributors on it.

How is this supposed to not be adversarial when I can't even use the Kernel source itself as a reference?

Tom
