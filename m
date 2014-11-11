From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next PATCH v3 4/5] fm10k/igb/ixgbe: Replace
 __skb_alloc_page with dev_alloc_page
Date: Tue, 11 Nov 2014 12:57:55 -0500 (EST)
Message-ID: <20141111.125755.706958311167301015.davem@davemloft.net>
References: <1415726904.2466.170.camel@jtkirshe-mobl>
	<20141111.124826.2036471212277751765.davem@davemloft.net>
	<1415728594.2466.173.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	mgorman-l3A5Bk7waGM@public.gmane.org
To: jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415728594.2466.173.camel@jtkirshe-mobl>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Tue, 11 Nov 2014 09:56:34 -0800

> On Tue, 2014-11-11 at 12:48 -0500, David Miller wrote:
>> I think this entire series will need to go via my tree, because the
>> conversions are all required for patch #5 which removes the replaced
>> interface altogether.
> 
> That is fine Dave, I think I mentioned that during Alex's v1 of the
> series.  I was just letting Alex know that we were going to test his
> changes, but feel free to pull the entire series.
> 
> I will give you my ACK
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Great, thanks for the clarification.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
