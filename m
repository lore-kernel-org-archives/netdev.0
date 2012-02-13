From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] drivers/net: Remove boolean comparisons to
 true/false
Date: Mon, 13 Feb 2012 00:50:25 -0500 (EST)
Message-ID: <20120213.005025.199077040083086801.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
	<20120209.133413.349832435589531136.davem@davemloft.net>
	<1328822243.29329.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328822243.29329.11.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 09 Feb 2012 13:17:23 -0800

> Booleans should not be compared to true or false
> but be directly tested or tested with !.
> 
> Done via cocci script:
 ...
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
