From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: mark expected switch fall-throughs
Date: Wed, 18 Oct 2017 13:59:30 +0100 (WEST)
Message-ID: <20171018.135930.629812750113492337.davem@davemloft.net>
References: <20171016204855.GA7470@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016204855.GA7470@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 16 Oct 2017 15:48:55 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Notice that in some cases I placed the "fall through" comment
> on its own line, which is what GCC is expecting to find.
> 
> Addresses-Coverity-ID: 115108
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
