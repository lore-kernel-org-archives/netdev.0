From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Tue, 24 Jun 2008 17:12:22 -0400
Message-ID: <20080624211222.GB25892@tuxdriver.com>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi> <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com> <1214298259.8967.260.camel@johannes.berg> <20080624124311.GC16021@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080624124311.GC16021-re2QNgSbS3j4D6uPqz5PAwR5/fbUUdgG@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2008 at 03:43:14PM +0300, Adrian Bunk wrote:

> Can we get one of either:
> - all selected mac80211 algorithms are built into the mac80211 module or

This seems fine to me.

> - all selected mac80211 algorithms (including the default one) are in
>   their own modules

We got here trying to avoid this one in the first place.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
