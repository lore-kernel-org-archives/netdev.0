From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: GIT net-2.6 rolled back 8 commits...
Date: Tue, 10 May 2011 15:08:14 -0700 (PDT)
Message-ID: <20110510.150814.226778453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


I made a mistake and applied to net-2.6 a patch from Eric Dumazet that
only is applicable for net-next-2.6

I really don't want to have to toss Linus that commit and a revert commit
just to fix it up.

So I rewound the net-2.6 tree by 8 commits.

So if you've pulled in the past 3 hours, please reset your pull and repull.

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
