From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: Patch: add loglevel to printk's in net/ipv4/route.c
Date: Wed, 29 Dec 2004 03:13:52 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412290312540.3528@dragon.hygekrogen.localhost>
References: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost>
 <41D2104D.3010406@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Juhl <juhl-lkml@dif.dk>,
	Networking Team <netdev@oss.sgi.com>,
	linux-net <linux-net@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41D2104D.3010406@conectiva.com.br>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Dec 2004, Arnaldo Carvalho de Melo wrote:

> Jesper Juhl wrote:
> > Small patch below adds loglevels to a few printk's in net/ipv4/route.c
> > 
[...]
> 
> Are you sure the output is much improved? ;)
> 
It doesn't make much difference, it's mostly for completeness/correctness.


-- 
Jesper

