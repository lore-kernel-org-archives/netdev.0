From: "Michal Piotrowski" <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [2/2] 2.6.22-rc5: known regressions with patches
Date: Wed, 20 Jun 2007 15:37:41 +0200
Message-ID: <6bffcb0e0706200637m33b02ea7le7c8f64c66e159b2@mail.gmail.com>
References: <4675430B.2000304@googlemail.com> <46754400.2080101@googlemail.com>
	 <20070618100905.7fc1176c@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Christoph Lameter" <clameter-sJ/iWh9BUns@public.gmane.org>,
	"Dave Airlie" <airlied-cv59FeDIM0c@public.gmane.org>,
	"Andrea Righi" <righiandr-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Samuel Ortiz" <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	"Andrey Borzenkov" <arvidjaar-JGs/UdohzUI@public.gmane.org>,
	"Bjorn Helgaas" <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>,
	"Chad Tindel" <ctindel-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"Dan Aloni" <da-x-KzBIeXn4Coe+51mZqJFLXQ@public.gmane.org>,
	"Jay Vosburgh" <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	"Stephen Smalley" <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
	"James Morris" <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	"Eric Paris" <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
	"Ingo Molnar" <mingo-X9Un+BFzKDI@public.gmane.org>,
	linux-usb-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"Paulo Pereira" <pfmp.404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: "Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070618100905.7fc1176c-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18/06/07, Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Sun, 17 Jun 2007 16:24:00 +0200
> Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> > Hi all,
> >
> > Here is a list of some known regressions in 2.6.22-rc5
> > with patches available.
> >
> > Feel free to add new regressions/remove fixed etc.
> > http://kernelnewbies.org/known_regressions
> >
> >
> >
> > Memory management
> >
> > Subject    : bug in i386 MTRR initialization
> > References : http://lkml.org/lkml/2007/5/19/93
> > Submitter  : Andrea Righi <righiandr-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> > Status     : patch available
> >
> >
> >
> > Networking
> > Subject    : commit 9093bbb2d96d0184f037cea9b4e952a44ebe7c32 broke the bonding driver
> > References : http://lkml.org/lkml/2007/6/13/65
> > Submitter  : Dan Aloni <da-x-KzBIeXn4Coe+51mZqJFLXQ@public.gmane.org>
> > Handled-By : Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > Status     : patch available
> >              (I cannot find it in archives. Stephen, please resend the patch)
> >
>
> http://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg40352.html

Thanks!

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
