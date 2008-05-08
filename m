From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read
	lock.
Date: Thu, 8 May 2008 14:53:23 -0400
Message-ID: <20080508185323.GB7250@tuxdriver.com>
References: <4820997E.1070305@openvz.org> <20080506.134047.86330538.davem@davemloft.net> <4821442D.8010801@openvz.org> <20080506.225950.181623233.davem@davemloft.net> <20080508185123.GA7250@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080508185123.GA7250-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 08, 2008 at 02:51:23PM -0400, John W. Linville wrote:
> On Tue, May 06, 2008 at 10:59:50PM -0700, David Miller wrote:
> 
> > Whether you should resubmit your patch is up to the wireless
> > folks :-)
> 
> If you don't do it Ingo Oeser's way then it looks like you would need
> a patch like the one below.  And with the patch below, the last hunk
> of your patch will probably need to be fixed-up to match.

Ah, sorry -- I guess I should have read the whole series before
commenting... :-)

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
