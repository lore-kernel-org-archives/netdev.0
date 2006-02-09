From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 8 Feb 2006 16:05:11 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0602081604530.1564@shark.he.net>
References: <20060208232214.GC14543@mipter.zuzino.mipt.ru>
 <E1F6z45-0006qL-00@gondolin.me.apana.org.au> <20060208.155859.82670094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, adobriyan@gmail.com,
	dlstevens@us.ibm.com, carlsonj@workingcode.com,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060208.155859.82670094.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Feb 2006, David S. Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 09 Feb 2006 10:49:37 +1100
>
> > The difference between gcc -pedantic and sparse is that it doesn't
> > warn about obviously correct cases like p != 0 or p = 0.
>
> So obviously correct that you left out an equals sign in the
> second case :-)

You should thank him.  8;)

-- 
~Randy
