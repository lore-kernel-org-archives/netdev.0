From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: iwl3945: regression - unregister_netdevice: waiting for wlan0
 to become free. Usage count = 1
Date: Mon, 22 Nov 2010 07:36:46 -0800 (PST)
Message-ID: <20101122.073646.193727189.davem@davemloft.net>
References: <20101122104341.GA3897@tiehlicka.suse.cz>
	<1290424776.2811.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1290424776.2811.32.camel@edumazet-laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 22 Nov 2010 12:19:36 +0100

> Oh well, it seems David put the fix in net-next-2.6 instead of net-2.6
> 
> Please try :
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=9d82ca98f71fd686ef2f3017c5e3e6a4871b6e46

My bad, I'll toss this into net-2.6

Thanks for catching this Eric.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
