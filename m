From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Sun, 14 Feb 2010 22:22:32 -0800 (PST)
Message-ID: <20100214.222231.180659633.davem@davemloft.net>
References: <20100215152023.0696878f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jouni.malinen@atheros.com,
	linville@tuxdriver.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100215152023.0696878f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 15 Feb 2010 15:20:23 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/mac80211/rate.c between commit
> 5affcd6ba2036b59a4dee3f0576ae3584e92e4f1 ("mac80211: fix handling of
> null-rate control in rate_control_get_rate") from the wireless-current
> tree and commit 37eb0b164cf9fa9f70c8500926f5cde7c652f48e
> ("cfg80211/mac80211: Use more generic bitrate mask for rate control")
> from the net tree.
> 
> John, I know you mentioned this, so I assume it will go away soon.
> 
> I fixed it up (I think - see below).

Right, I'll even try to take care of this myself later tonight.
