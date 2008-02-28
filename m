From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-28
Date: Thu, 28 Feb 2008 11:22:29 -0800 (PST)
Message-ID: <20080228.112229.135415548.davem@davemloft.net>
References: <20080228014125.GI3078@tuxdriver.com>
	<20080227.235110.242439399.davem@davemloft.net>
	<20080228145136.GD3063@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080228145136.GD3063-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 28 Feb 2008 09:51:36 -0500

> This version drops the "Fix b43 drivers build for arm" patch, and adds a
> one-line build fix for SSB-attached PCI cores (found on bcm47xx mips).

Thanks.

> P.S. This will create a merge conflict with the code I already
> requested that you pull for net-2.6.26.  The merge is easily resolved,
> since it is two "comment block + single statement" additions at the
> same place in the file.  Just take both sets of changes, and order
> the "Evalue antenna setup" group _after_ the "Send a signal to the
> led" group.  I have the conflict corrected in my wireless-testing
> tree for reference if you need it.

Understood.

> The following changes since commit d9595a7b9c777d45a74774f1428c263a0a47f4c0:
>   David S. Miller (1):
>         [AF_KEY]: Fix oops by converting to proc_net_*().
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Pulled and pushed back out, thanks John!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
