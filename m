From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: check the length of the data before
 dereferencing it
Date: Mon, 2 Apr 2012 11:05:21 +0800
Message-ID: <CABa6K_GZJ-uCsfz63O9t_dZ2o9DvYHHraW297esOSqZn2Ejnzg@mail.gmail.com>
References: <1333290170-26898-1-git-send-email-xiaosuo@gmail.com>
 <20120401164325.GB10861@1984> <1333299322.2325.5277.camel@edumazet-glaptop> <20120401170226.GA11101@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120401170226.GA11101@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 2, 2012 at 1:02 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>
> Indeed, then I think we need a similar patch for tcp_parse_options()
> in net/ipv4/tcp_input.c

I'll send a separated patch for it. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
