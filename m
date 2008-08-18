From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: ath5k text
Date: Mon, 18 Aug 2008 00:05:13 -0700 (PDT)
Message-ID: <20080818.000513.224752343.davem@davemloft.net>
References: <20080817185605.GC30679@tuxdriver.com>
	<20080817.151251.204370966.davem@davemloft.net>
	<48A91E12.1060901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-53cgGKa3i4734X6bwOH/f4/+3M+ant7aZ+vKCSbpVNE@public.gmane.org
To: jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48A91E12.1060901-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 18 Aug 2008 09:00:34 +0200

> On 08/18/2008 12:12 AM, David Miller wrote:
> > Their commit messages reference SHA IDs but do not give a commit
> > header line text reference as well.
> > 
> >       ath5k: Don't fiddle with MSI on suspend/resume.
> 
> John, this is it (even if I don't understand the purpose):

The purpose is that when patches are backported or moved to
other GIT trees, the SHA ID is going to be different.

So when you reference just the SHA ID it is not enough
infomration to universally find the commit you are referring
to.

Do you understand "the purpose" now? :-)

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
