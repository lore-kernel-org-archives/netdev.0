From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-01-12
Date: Tue, 13 Jan 2009 11:34:55 -0500
Message-ID: <20090113163455.GC3623@tuxdriver.com>
References: <20090112201302.GB3786@tuxdriver.com> <20090112.212345.259792227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090112.212345.259792227.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2009 at 09:23:45PM -0800, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 12 Jan 2009 15:13:02 -0500
> 
> > Please let me know if there are problems!
> 
> There's something funny in this tree.   In changeset
> 19f0a391bf9d88307e52557ff3125b24e2519bd4 there is
> a removal of arch/arm/mach-integrator/clock.h
> 
> I think when you installed that commit something
> automatically deleted zero length files it found,
> but that's just a guess.
> 
> Please fix this up so I can pull from you.
> 
> Otherwise all of those changes looked fine.
 
Hmmm...dirty tree I suppose.  Sorry about that!  I should have noticed
that in the changelog.

I'll post a new pull request immediately.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
