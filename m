From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Mon, 15 Jun 2009 15:32:06 -0700
Message-ID: <20090615223206.GA4966@kroah.com>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com> <20090615201934.GA12685@kroah.com> <20090615214735.GE23972@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090615214735.GE23972-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2009 at 05:47:35PM -0400, Luis R. Rodriguez wrote:
> From: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> Subject: [PATCH] Documentation: add documentation summary for rc-series and merge window
> 
> This is losely based on previous discussions on linux-kernel [1][2].
> Lets also refer people reading the stable rules to
> Documentation/development-process/.
> 
> [1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
> [2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2
> 
> Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> ---
>  Documentation/development-process/2.Process |   66 +++++++++++++++++++++++++++
>  Documentation/stable_kernel_rules.txt       |    5 ++
>  2 files changed, 71 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
> index d750321..e023db6 100644
> --- a/Documentation/development-process/2.Process
> +++ b/Documentation/development-process/2.Process

You should cc: the author of this document, when modifying it.

> @@ -7,6 +7,72 @@ course of one year, the kernel has since had to evolve a number of
>  processes to keep development happening smoothly.  A solid understanding of
>  how the process works is required in order to be an effective part of it.
>  
> +2.0 SUMMARY
> +
> +This section provides a brief summary of the new kernel release rules.
> +
> +2.0.0 NEW KERNEL RELEASE RULES

"New"?  We've been doing this for many many years now, what is "new"
about it?

And why are you starting a series with "0"?  Just to keep from having to
modify all of the other numbers?  None of the other files in this
directory start at 0...

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
