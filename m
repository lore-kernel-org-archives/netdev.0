From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network
 namespaces
Date: Mon, 15 Jun 2015 17:10:42 -0700 (PDT)
Message-ID: <20150615.171042.1771913051598016582.davem@davemloft.net>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	stephen@networkplumber.org, jjciarla@raiz.uncu.edu.ar,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	jhs@mojatatu.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
To: ebiederm@xmission.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 14 Jun 2015 22:07:30 -0500

> While looking into what it would take to route packets out to network
> devices in other network namespaces I started looking at the netfilter
> hooks, and there is a lot of nasty code to figure out which network
> namespace to filter the packets in.

I am assume that you and Pablo are going to look at eachother's
work and decide how to proceed and therefore I'm getting another
series to actually apply at some point in the future.
