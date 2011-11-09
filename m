From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 10:43:09 +0800
Message-ID: <1683717478.20111109104309@mail.ru>
References: <20111108.204253.891598837549584662.davem@davemloft.net> <20111109015406.GA10800@gondor.apana.org.au>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	<linux-crypto@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>,
	<adobriyan@gmail.com>, <peter.p.waskiewicz.jr@intel.com>,
	<davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20111109015406.GA10800@gondor.apana.org.au>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Alternatively you can do this with marking and use netfilter
> to set the mark.

> Cheers,

We focus on connections to devices zywall. If you choose to zywall IP range as the remote side will not harmonize policies. The connection is not established. And this alternative makes no sense.

Regards
Daniil Stolnikov

