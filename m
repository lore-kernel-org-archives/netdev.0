From: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Subject: Re: [PATCH] ath10k: match wait_for_completion_timeout return type
Date: Fri, 13 Mar 2015 18:34:05 +0100
Message-ID: <20150313173405.GB9934@opentech.at>
References: <1426094076-10134-1-git-send-email-hofrat@osadl.org> <87y4n0q1rq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87y4n0q1rq.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Mar 2015, Kalle Valo wrote:

> Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org> writes:
> 
> > Return type of wait_for_completion_timeout is unsigned long not int.
> > An appropriately named unsigned long is added and the assignments fixed up.
> >
> > Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
> 
> Doesn't apply:
> 
> Applying: ath10k: match wait_for_completion_timeout return type
> fatal: sha1 information is lacking or useless (drivers/net/wireless/ath/ath10k/mac.c).
> Repository lacks necessary blobs to fall back on 3-way merge.
> Cannot fall back to three-way merge.
> Patch failed at 0001 ath10k: match wait_for_completion_timeout return type
>
sorry - no idea how I managed that - checking it.

Will fix it up and repost.

thx!
hofrat
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
