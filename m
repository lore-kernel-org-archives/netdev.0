From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 10:32:07 +0800
Message-ID: <552673196.20111109103207@mail.ru>
References: <CACVxJT887ATwt97iw7mPEkH+KXgy1WbsP_aUB_X-8uLQ+6YsLQ@mail.gmail.com> <20111108.121620.2044664919065812135.davem@davemloft.net> <1289495586.20111109093607@mail.ru> <20111108.204253.891598837549584662.davem@davemloft.net>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	<linux-crypto@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>,
	<adobriyan@gmail.com>, <peter.p.waskiewicz.jr@intel.com>,
	<herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20111108.204253.891598837549584662.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Like I said, if you want address ranges, ask the userland IPSEC daemon
> authors to synthesize it.

In this letter, the mailing list http://marc.info/?l=strongswan-users&m=130613736616488&w=4 strongswan-users say that their product has support for IP ranges, but the stack of Linux is based on network masks. So I do not understand how this would work without the support at the kernel level? How will coordination of policies?
