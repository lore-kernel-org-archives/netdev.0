From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Sat, 18 Sep 2004 01:22:31 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <9e473391040917222253f8bf03@mail.gmail.com>
References: <9e47339104091717215e9be08b@mail.gmail.com>
	 <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
	 <9e473391040917183726113e91@mail.gmail.com>
	 <20040918041627.GA12356@gondor.apana.org.au>
Reply-To: Jon Smirl <jonsmirl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, david@gibson.dropbear.id.au, akpm@osdl.org,
	trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267555AbUIRFWj@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040918041627.GA12356@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org

Still getting the same fault with the patch. Someone else has this
problem too. The full stack trace is in this thread....

[2.6.9-rc2-bk] Network-related panic on boot  

-- 
Jon Smirl
jonsmirl@gmail.com
