From: "David S. Miller" <davem@davemloft.net>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (126)
Date: Thu, 31 Mar 2005 11:19:42 -0800
Message-ID: <20050331111942.1ded085d.davem@davemloft.net>
References: <20050327091524.GA23215@elte.hu>
	<E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
	<20050327133811.GA5569@elte.hu>
	<20050329104906.GA19836@gondor.apana.org.au>
	<20050329114926.GA14986@elte.hu>
	<20050330082640.GA8269@gondor.apana.org.au>
	<20050330170236.2bddf666.davem@davemloft.net>
	<20050331011001.GA26715@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050331011001.GA26715@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 11:10:01 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Mar 30, 2005 at 05:02:36PM -0800, David S. Miller wrote:
> > 
> > Looks like 2.4.x needs the same fix, correct?
> 
> Indeed it does.  Here it is for 2.4.

Applied, thanks Herbert.
