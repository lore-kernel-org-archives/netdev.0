From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Wed, 29 Oct 2008 19:33:51 -0400
Message-ID: <20081029233350.GE3485@tuxdriver.com>
References: <20081029231855.GD3485@tuxdriver.com> <20081029162324.28f5864d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org, mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081029162324.28f5864d-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2008 at 04:23:24PM -0700, Arjan van de Ven wrote:
> On Wed, 29 Oct 2008 19:18:55 -0400
> "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> 
> > Dave,
> > 
> > Another quick round of fixes intended for 2.6.28...
> > 
> > This includes fixes for bugs 11749 and 11845, fixes a reset-related
> > regression in ath5k, fixes a Kconfig-related error for rt2x00, and
> > fixes some sparse warnings and a possible buffer overrun in libertas.
> > Also, it corrects a spelling error and marks Bob Copeland as an
> > ath5k maintainer.
> 
> speaking of ath5k:
> 
> http://www.kerneloops.org/version.php?start=1835008&end=1867775&version=28-rc
> 
> it seems to have added a few WARN_ON()s which now end up at the top of
> the list .. are these known or should I spend some time writing reports
> for netdev ?

I wasn't aware of them -- thanks... :-)

-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
