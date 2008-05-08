From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: New GIT net tree naming...
Date: Wed, 7 May 2008 21:43:58 -0400
Message-ID: <20080508014358.GE3412@tuxdriver.com>
References: <20080419.173510.257216556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080419.173510.257216556.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 19, 2008 at 05:35:10PM -0700, David Miller wrote:
> 
> Based upon feedback from Andrew and others I'm now starting
> to use a new naming scheme for my GIT trees:
> 
> For changes against Linus's current tree:
> 
>    master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> For development meant to be merged in the next merge
> window we have:
> 
>    master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> 
> Andrew/Stephen, let me know if this works for you.  This way
> the tree names will never change.

I have adopted this same scheme for wireless as well:

For changes against Linus's current tree:

   master.kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git

For development meant to be merged in the next merge
window we have:

   master.kernel.org:/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
