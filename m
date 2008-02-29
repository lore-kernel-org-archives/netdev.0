From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Fri, 29 Feb 2008 11:26:29 -0500
Message-ID: <20080229162629.GB3234@tuxdriver.com>
References: <20080228014125.GI3078@tuxdriver.com> <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com> <20080228.133008.228590007.davem@davemloft.net> <200802291316.59738.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200802291316.59738.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 29, 2008 at 01:16:59PM +0100, Michael Buesch wrote:

> I'm wondering if we can't simply pass a commandline parameter to file2alias
> that tells it whether we are crosscompiling. It should simply omit the sanity check

Sounds reasonable to me.

> in that case. Is there any easy and reliable way to find out whether we
> are crosscompiling from a makefile (I don't know the makefile core that much)?

Non-empty CROSS_COMPILE definition?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
