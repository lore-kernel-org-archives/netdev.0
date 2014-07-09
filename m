From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next PATCH v2 0/3] Broadcast/Multicast rate limit via
 Ethtool Coalesce
Date: Wed, 09 Jul 2014 16:44:20 -0700 (PDT)
Message-ID: <20140709.164420.157865201153845876.davem@davemloft.net>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mugunthanvnm-l0cyMroinI0@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1404890050-4020-1-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Date: Wed, 9 Jul 2014 12:44:07 +0530

> A system/cpu can be loaded by a hacker with flooding of broadcast or
> multicast packets, to prevent this some Ethernet controllers like CPSW
> provide a mechanism to limit the broadcast/multicast packet rate via
> hardware limiters. This patch series enables this feature via
> Ethtool Coalesce.

This is pretty bogus if you ask me.

What is the difference from accepting a high rate of unicast packets?
I say it is no different.

Therefore, this feature makes no sense to me at all.
