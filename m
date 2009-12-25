From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-12-24
Date: Fri, 25 Dec 2009 11:38:01 -0500
Message-ID: <20091225163801.GA4481@tuxdriver.com>
References: <20091224204722.GA678@tuxdriver.com> <20091224.135314.193725771.davem@davemloft.net> <20091225044759.GA11186@tuxdriver.com> <20091225005142.ixwgpr0dcg4cc48w-cebfxv@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091225005142.ixwgpr0dcg4cc48w-cebfxv-2RFepEojUI3Rd1RZctBqVdHuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 25, 2009 at 12:51:42AM -0500, Pavel Roskin wrote:
> Quoting "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
>
>> Hmm...well, I'm at a loss.  It certainly works here. :-)
>
> You may want to see this discussion in LKML:
> http://thread.gmane.org/gmane.linux.kernel/928654/
>
> The error messages look differently though.  Anyway, genregdb.awk  
> appears to require gawk.

Perhaps, but not intentionally.  Hopefully the patch I posted is
sufficient to get things working for non-gawk users...?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
