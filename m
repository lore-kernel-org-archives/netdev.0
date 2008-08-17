From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-17
Date: Sun, 17 Aug 2008 15:12:51 -0700 (PDT)
Message-ID: <20080817.151251.204370966.davem@davemloft.net>
References: <20080817185605.GC30679@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080817185605.GC30679-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Sun, 17 Aug 2008 14:56:06 -0400

> Here is the latest round of wireless fixes for 2.6.27.  The silliest one
> is the one from Adrian Bunk, which applies the gcc-related fix to ath9k
> again because there were two identical pieces of code to fix -- I guess
> I didn't get the joke *facepalm*...
> 
> I don't think there is anything else remarkable, although I think we fix
> a couple of the current regressions on LKML.

Two commits in here need a fixup.

Their commit messages reference SHA IDs but do not give a commit
header line text reference as well.

      p54: Fix regression due to commit b19fa1f
      ath5k: Don't fiddle with MSI on suspend/resume.

Please fix this up and give me another pull request, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
