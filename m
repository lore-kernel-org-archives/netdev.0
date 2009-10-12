From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
 2.6.32-rc3)
Date: Mon, 12 Oct 2009 16:24:29 -0700
Message-ID: <20091012232429.GA24254@suse.de>
References: <alpine.LFD.2.01.0910081255510.3432@localhost.localdomain>
 <20091008210737.GD29181@mit.edu>
 <alpine.LFD.2.01.0910081410400.3432@localhost.localdomain>
 <20091009091538.GA4154@elte.hu>
 <1255097287.2934.21.camel@localhost.localdomain>
 <20091012130652.GB25464@elte.hu>
 <1255357148.2850.91.camel@localhost.localdomain>
 <20091012145453.GD4565@elte.hu>
 <20091012150911.GB1656@suse.de>
 <20091012154244.GA13323@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jing Huang <huangj-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091012154244.GA13323-X9Un+BFzKDI@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2009 at 05:42:44PM +0200, Ingo Molnar wrote:
> Hm, i think i even gave drivers/staging/ its name?

Yes you did, and I appreciate it :)

> > [...] It seems that I'm the only one that has the ability to drop 
> > drivers out of the kernel tree, which is a funny situation :)
> 
> You are the only one who has the ability to send a warning shot towards 
> drivers _without hurting users_, and by moving it into the focus of a 
> team of cleanup oriented developers.
> 
> I think that's an important distinction ;-)

Good point.

> > In thinking about this a lot more, I don't really mind it.  If people 
> > want to push stuff out of "real" places in the kernel, into 
> > drivers/staging/ and give the original authors and maintainers notice 
> > about what is going on, _and_ provide a TODO file for what needs to 
> > happen to get the code back into the main portion of the kernel tree, 
> > then I'll be happy to help out with this and manage it.
> > 
> > I think a 6-9 month window (basically 3 kernel releases) should be 
> > sufficient time to have a driver that has been in drivers/staging/ be 
> > cleaned up enough to move back into the main kernel tree.  If not, it 
> > could be easily dropped.
> > 
> > Any objections to this?
> 
> Sounds excellent to me!

Great, I'll await the patches to move stuff to drivers/staging/ now.

Wireless developers, warm up your editors :)

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
