From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: mark expected switch fall-throughs
Date: Wed, 18 Oct 2017 14:13:36 +0100 (WEST)
Message-ID: <20171018.141336.2118773277800673996.davem@davemloft.net>
References: <20171016213652.GA9967@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016213652.GA9967@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 16 Oct 2017 16:36:52 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Notice that in some cases I placed the "fall through" comment
> on its own line, which is what GCC is expecting to find.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
