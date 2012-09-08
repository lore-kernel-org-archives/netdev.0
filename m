From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: x_tables: xt_init() should run
 earlier
Date: Sat, 08 Sep 2012 21:50:41 +0200
Message-ID: <1347133841.1234.1033.camel@edumazet-glaptop>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
	 <1346860506.13121.148.camel@edumazet-glaptop>
	 <1346861569.13121.149.camel@edumazet-glaptop>
	 <1346863073.13121.155.camel@edumazet-glaptop>
	 <Pine.GSO.4.63.1209081949500.2030@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1209081949500.2030@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-09-08 at 19:50 +0200, Patrick McHardy wrote:

> Shouldn't we simply change the Makefile order?

Yes, this is what Pablo did.


