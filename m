From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Fri, 5 Nov 2010 11:10:23 -0400 (EDT)
Message-ID: <alpine.LNX.2.00.1011051108270.15851@pobox.suse.cz>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>  <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>  <1288938640.3234.12.camel@edumazet-laptop> <1288940146.18440.55.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Juhl <jj@chaosbits.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288940146.18440.55.camel@Joe-Laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Nov 2010, Joe Perches wrote:

> I also think a single rolled-up single patch is good.
> 
> I believe Jiri Kosina can easily apply all these individual patches as a 
> single patch if he chooses.

I will, after this settles a little bit (the same for the WARN series). 
I prefer waiting a bit before applying your patches usually. 

First to see what lands in linux-next through maintainer's trees, second 
to gather Acks.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
