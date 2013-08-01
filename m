From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] include/net: next set of extern removals
Date: Wed, 31 Jul 2013 17:50:36 -0700 (PDT)
Message-ID: <20130731.175036.1962194560242893587.davem@davemloft.net>
References: <cover.1375316912.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-hams@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: joe@perches.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 31 Jul 2013 17:31:31 -0700

> Standardize on no extern use on function prototypes
> 
> Joe Perches (8):
>   addrconf.h: Remove extern function prototypes
>   af_unix.h: Remove extern from function prototypes
>   af_rxrpc.h: Remove extern from function prototypes
>   arp/neighbour.h: Remove extern from function prototypes
>   ax25.h: Remove extern from function prototypes
>   cfg80211.h/mac80211.h: Remove extern from function prototypes
>   checksum: Remove extern from function prototypes
>   cls_cgroup.h netprio_cgroup.h: Remove extern from function prototypes

I guess there is no time like the present to apply something like
this, so I have.

Please hold off for a few days before the next batch so we can watch
for any fallout from this one.

Thanks Joe.
