From: "Nick Kossifidis" <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/5] Net: ath5k, use int as retval
Date: Sun, 2 Sep 2007 18:55:15 +0300
Message-ID: <40f31dec0709020855q10d9227bld6e594ea57ba8142@mail.gmail.com>
References: <2713029743177393055@pripojeni.net>
	 <2440910618305782004@pripojeni.net>
	 <20070830124054.GC5140@tuxdriver.com> <46D9C6A8.7070600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46D9C6A8.7070600-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2007/9/1, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> John W. Linville napsal(a):
> > On Tue, Aug 28, 2007 at 12:00:09PM -0400, Jiri Slaby wrote:
> >> ath5k, use int as retval
> >>
> >> Convert some functions to return int and proper negative return value on
> >> error as we are used to.
> >
> > Since I didn't apply 1/5, this one didn't apply either.  It seems
> > fine overall, so if you rediff I'll be happy to apply.
>
> Ok, I'll do it, thanks,

Can somebody commit my resent changes from madwifi-svn (cleanups,
kconfig, remove_hw_ from filenames etc) ? I don't have git repository
;-(


-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
