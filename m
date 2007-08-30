From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 3/5] Net: ath5k, use int as retval
Date: Thu, 30 Aug 2007 08:40:54 -0400
Message-ID: <20070830124054.GC5140@tuxdriver.com>
References: <2713029743177393055@pripojeni.net> <2440910618305782004@pripojeni.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2440910618305782004-+5AFNAhbZwkm4RdzfppkhA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 28, 2007 at 12:00:09PM -0400, Jiri Slaby wrote:
> ath5k, use int as retval
> 
> Convert some functions to return int and proper negative return value on
> error as we are used to.

Since I didn't apply 1/5, this one didn't apply either.  It seems
fine overall, so if you rediff I'll be happy to apply.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
