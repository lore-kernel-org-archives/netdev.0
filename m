From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless 2014-08-14
Date: Fri, 15 Aug 2014 10:30:14 -0400
Message-ID: <20140815143014.GK4953@tuxdriver.com>
References: <20140814183253.GF4953@tuxdriver.com>
 <20140814.151809.1355093138463959620.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140814.151809.1355093138463959620.davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2014 at 03:18:09PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Thu, 14 Aug 2014 14:32:53 -0400
> 
> > Please pull this batch of fixes intended for the 3.17 stream...
> > 
> > Arend van Spriel brings two brcmfmac fixes, one which fixes a memory
> > leak and one which corrects some merge damage.
> > 
> > Emmanuel Grumbach fixes Linus's iwlwifi firmware-related log spam.
> > 
> > Rickard Strandqvist does some proper NULL termination after a call
> > to strncpy.
> > 
> > Ronald Wahl corrects a carl9170 problem with sending URBs with the
> > wrong endpoint type (resulting in log spam).
> > 
> > Please let me know if there are problems!
> 
> Pulled, thanks John.
> 
> I'm really happy that you send the iwlwifi regression fix so quickly!

One-liners with a "Tested-by: Linus Torvalds" get a lot of respect... :-)

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
