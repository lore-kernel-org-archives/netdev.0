From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 25 Sep 2012 07:23:22 +0200
Message-ID: <1348550602.26828.1918.camel@edumazet-glaptop>
References: <20120925123438.bbf3126889513ee5cc195e5c@canb.auug.org.au>
	 <1348549842.26828.1897.camel@edumazet-glaptop>
	 <20120925.011343.1495275645575636949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120925.011343.1495275645575636949.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-25 at 01:13 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 25 Sep 2012 07:10:42 +0200
> 
> > Oops, my bad, net/ipv4/raw.c changes in 5640f7685831 ("net: use a per
> > task frag allocator") should not be there :
> > 
> > I accidentally left a debugging version of the patch I sent to fix the
> > icmp bug.
> > 
> > Sorry David for this, I am not sure how I can help on this ?
> 
> The thing to do is send me a patch to revert the raw.c change from
> net-next, right?

Sure, I'll do that after my breakfast and some coffee ;)
