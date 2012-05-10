From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 0/3] staging: delete duplicated files/functionality in
 rtl8712
Date: Thu, 10 May 2012 11:11:55 -0700
Message-ID: <20120510181155.GA8307@kroah.com>
References: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
 <20120510165451.GA12958@kroah.com>
 <20120510173139.GA16704@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	florian.c.schilhabel-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, ali-H4aWS73dXuqdkR0RstYxLQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120510173139.GA16704-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2012 at 01:31:39PM -0400, Paul Gortmaker wrote:
> [Re: [PATCH 0/3] staging: delete duplicated files/functionality in rtl8712] On 10/05/2012 (Thu 09:54) Greg Kroah-Hartman wrote:
> 
> [...]
> 
> > Can you regenerate these with the full deletion content?  There have
> > been some spelling fixes in these files, and your patches do not apply
> > due to them.  I can hand-edit the patches if you regenerate it.
> > 
> > Or if you rebase on the last linux-next tree, that will pick those
> > changes up and then I can apply these properly.
> 
> I've rebased it onto your staging-next of today, so it should be
> hopefully seamless for you now.

Yes, that was even easier, now pulled and pushed out, thanks.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
