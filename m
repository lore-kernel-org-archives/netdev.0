From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless 2013-06-03
Date: Tue, 4 Jun 2013 16:56:30 -0400
Message-ID: <20130604205630.GA11199@tuxdriver.com>
References: <20130603184817.GD2727@tuxdriver.com>
 <20130604.131813.134898245916084893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130604.131813.134898245916084893.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 04, 2013 at 01:18:13PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 3 Jun 2013 14:48:17 -0400
> 
> > Please let me know if there are problems!
> 
> Sorry, the broadcom brcmfmac changes need to go.
> 
> Some of those commits are cleanups, and some of them have the worst
> commit log messages ever, the last one for example:
> 
> 0017-brcmsmac-fix-regression-observed-in-3.10-rc1.patch
> 
> has no explanation whatsoever of what the actual problem or regression
> is, what aspect of the logic in that function is causing the problem,
> and no explanation why making this function always return 'false' is a
> reasonable fix.
> 
> That entire series is of very low quality, and even if it was in good
> shape, at least half the changes are not appropriate at all this late
> in the -rc series.

OK, sorry Dave -- I knew better...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
