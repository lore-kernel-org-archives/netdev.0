From: "David S. Miller" <davem@davemloft.net>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (126)
Date: Thu, 31 Mar 2005 20:33:13 -0800
Message-ID: <20050331203313.57e1c5c3.davem@davemloft.net>
References: <20050327091524.GA23215@elte.hu>
	<E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
	<20050327133811.GA5569@elte.hu>
	<20050329104906.GA19836@gondor.apana.org.au>
	<20050329114926.GA14986@elte.hu>
	<20050330082640.GA8269@gondor.apana.org.au>
	<20050330170236.2bddf666.davem@davemloft.net>
	<20050331231922.GA26587@gondor.apana.org.au>
	<20050331232322.GA26693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050331232322.GA26693@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 1 Apr 2005 09:23:22 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> Here is the version for 2.4.
>  
> Unfortunately my patch only closed half the race.

Both applied, thanks Herbert.
