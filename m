From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm PATCH][4/4] net: signed vs unsigned cleanup in
 net/ipv4/raw.c
Date: Wed, 15 Jun 2005 14:41:16 -0700 (PDT)
Message-ID: <20050615.144116.41632938.davem@davemloft.net>
References: <Pine.LNX.4.62.0506152316060.3842@dragon.hyggekrogen.localhost>
	<20050615.142953.59469324.davem@davemloft.net>
	<Pine.LNX.4.62.0506152338450.3842@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        ross.biro@gmail.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: juhl-lkml@dif.dk
In-Reply-To: <Pine.LNX.4.62.0506152338450.3842@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <juhl-lkml@dif.dk>
Date: Wed, 15 Jun 2005 23:40:12 +0200 (CEST)

> On Wed, 15 Jun 2005, David S. Miller wrote:
> 
> > I think I'd prefer that.
> > 
> No problem. Here's a replacement patch nr. 4 : 

Thanks a lot.  All 4 patches applied to my 2.6.13-pending tree.
