From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Patch: add loglevel to printk's in net/ipv4/route.c
Date: Wed, 29 Dec 2004 00:10:22 -0200
Message-ID: <41D2120E.8030008@conectiva.com.br>
References: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost> <41D2104D.3010406@conectiva.com.br> <Pine.LNX.4.61.0412290312540.3528@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking Team <netdev@oss.sgi.com>,
	linux-net <linux-net@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.61.0412290312540.3528@dragon.hygekrogen.localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jesper Juhl wrote:
> On Wed, 29 Dec 2004, Arnaldo Carvalho de Melo wrote:
> 
> 
>>Jesper Juhl wrote:
>>
>>>Small patch below adds loglevels to a few printk's in net/ipv4/route.c
>>>
> 
> [...]
> 
>>Are you sure the output is much improved? ;)
>>
> 
> It doesn't make much difference, it's mostly for completeness/correctness.

No, it does a helluva difference, give it a try :-)

- Arnaldo
