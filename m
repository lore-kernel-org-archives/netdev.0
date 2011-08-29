From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] iwlegacy: change IWL_WARN to IWL_DEBUG_HT in
 iwl4965_tx_agg_start
Date: Mon, 29 Aug 2011 14:20:15 +0200
Message-ID: <20110829122013.GA3597@redhat.com>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314537977-20097-1-git-send-email-Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 28, 2011 at 08:26:16AM -0500, Greg Dietsche wrote:
> This message should be a debug message and not a warning. So
> change it from IWL_WARN to IWL_DEBUG_HT.

I'm currently doing massive iwlegacy driver cleanup. Would be easier
for me to apply these patches on top of my changes instead of rebase
my patches. I will queue these two patches and post them together with
my pending patches.

Thanks
Stanislaw  
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
