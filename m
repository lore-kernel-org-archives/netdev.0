From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 21:00:02 +0900 (JST)
Message-ID: <20050220.210002.59645733.yoshfuji@linux-ipv6.org>
References: <42184BC2.1030907@trash.net>
	<20050220111219.GA25499@gondor.apana.org.au>
	<4218729A.4080201@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
To: kaber@trash.net
In-Reply-To: <4218729A.4080201@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4218729A.4080201@trash.net> (at Sun, 20 Feb 2005 12:20:58 +0100), Patrick McHardy <kaber@trash.net> says:

> Herbert Xu wrote:
> > It is looking more and more like a nasty hack though so maybe
> > it's not worth it since the policy checks are still bloated enough
> > even after we do this.
> 
> Agreed. Let's just take the first patch.

I totally agree. I belive it is the safest fix.

--yoshfuji
