From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
 using ethtool
Date: Fri, 16 May 2014 22:40:32 -0400 (EDT)
Message-ID: <20140516.224032.2301577488192248796.davem@davemloft.net>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 16 May 2014 21:48:17 +0200

> Quoting the previous description of this series (skip to the
> changelog below if you only want a summary of the changes):

Ok I'm fine with this, applied to net-next.

Just make doubly sure that you will be ok, for a long time, with using
the ethtool coalescing interface for configuring this because you'll
really be stuck with this forever.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
