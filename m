From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 3/5] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Fri, 05 Jun 2009 15:23:17 +0200
Message-ID: <1244208197.23850.22.camel@localhost.localdomain>
References: <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
	 <1244184737.22576.94.camel@johannes.local>
	 <20090605071529.GA7064@doriath.ww600.siemens.net>
	 <20090605.005418.07362083.davem@davemloft.net>
	 <20090605091229.GA25280@doriath.ww600.siemens.net>
	 <20090605094619.GB23085@build.ossfans.org>
	 <bc64b4640906050345t5ed23d7bxc8a777a4a0ada147@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bc64b4640906050345t5ed23d7bxc8a777a4a0ada147-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

> > Dmitry, please toss all my @siemens.com addresses from all patches, since my
> > access is already disabled and it's pointless to have invalid emails
> > in source tree. Please replace them with @ossfans.org ones.
> 
> Could you please send an incremental patch on top of this serie? I
> hope that my last
> push can be pulled/merged and I don't want to redo all commits.

either start getting used to git-rebase or manual rebase of commits. You
better be familiar with git before asking people to merge. We are
expecting you to provide proper trees to pull from a patches to apply.

And since Dave and Johannes already asked you to fix the __KERNEL__ part
you have to redo the pull request anyway.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
