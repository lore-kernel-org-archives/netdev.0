From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (122)
Date: Thu, 12 May 2005 00:20:41 +0900 (JST)
Message-ID: <20050512.002041.-1300550735.chamas@h4.dion.ne.jp>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
	<20050510220751.GA459@gondor.apana.org.au>
	<20050511005836.GA1674@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050511005836.GA1674@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 Hello.

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Wed, 11 May 2005 10:58:36 +1000

> Please let me know whether this works for you or not.

It worked, thank you.
