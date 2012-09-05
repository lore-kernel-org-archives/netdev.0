From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: x_tables: xt_init() should run
 earlier
Date: Wed, 05 Sep 2012 18:59:36 +0200
Message-ID: <1346864376.13121.159.camel@edumazet-glaptop>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
	 <1346860506.13121.148.camel@edumazet-glaptop>
	 <1346861569.13121.149.camel@edumazet-glaptop>
	 <1346863073.13121.155.camel@edumazet-glaptop> <20120905165321.GA22243@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120905165321.GA22243@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 18:53 +0200, Pablo Neira Ayuso wrote:
> Hi Eric,

> 
> It seems we've clashed fixing this, sorry. Can you still see any
> problem with my patch?
> 
> Thanks for looking into this.

No problem !

It seems link order is the way to go, so your patch is good too !

Thanks


