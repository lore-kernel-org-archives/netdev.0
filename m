From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Add support for SIOCGIWRATE ioctl to provide
 rate information
Date: Mon, 02 Jul 2007 22:38:54 -0700 (PDT)
Message-ID: <20070702.223854.78161801.davem@davemloft.net>
References: <20070610.181704.73383002.davem@davemloft.net>
	<20070612012228.GG20422@tuxdriver.com>
	<20070612012319.GH20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070612012319.GH20422-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 11 Jun 2007 21:23:19 -0400

> From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> 
> At present, transmission rate information for mac80211 is available only
> if verbose debugging is turned on, and then only in the logs. This patch
> implements the SIOCGIWRATE ioctl, which adds the current transmission rate to
> the output of iwconfig.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

This change appears to already be in the tree.
