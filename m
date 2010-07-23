From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH V3] Export SMBIOS provided firmware instance and label to sysfs
Date: Fri, 23 Jul 2010 09:58:09 -0500
Message-ID: <20100723145809.GA7629@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612C40@blrx3m08.blr.amer.dell.com> <20100723133456.GA9378@auslistsprd01.us.dell.com> <20100723135557.GA3624@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <Narendra_K@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:39399 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758847Ab0GWO6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 10:58:22 -0400
Content-Disposition: inline
In-Reply-To: <20100723135557.GA3624@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 06:55:57AM -0700, Greg KH wrote:
> On Fri, Jul 23, 2010 at 08:34:56AM -0500, Narendra K wrote:
> > --- a/Documentation/ABI/testing/sysfs-bus-pci
> > +++ b/Documentation/ABI/testing/sysfs-bus-pci
> > @@ -179,3 +179,30 @@ Contact:	linux-pci@vger.kernel.org
> >  Description:
> >  		This symbolic link points to the PCI hotplug controller driver
> >  		module that manages the hotplug slot.
> > +
> > +What:		/sys/bus/pci/devices/.../label
> > +Date:		July 2010
> > +Contact:	linux-bugs@dell.com
> 
> that's not your email address.  Please don't hide behind some random
> address, Linux is about contacting developers directly were ever
> possible.

That's actually the public email address for the whole Linux
engineering team (including engineers and managers) at Dell, of which
Narendra is a part.  It's the address we publish for people to include
on the cc: list of bugzilla issues on the kernel.org, Novell, and Red
Hat bugzillas.  This ensures someone on the team will see bug reports
or patches and act accordingly, likely Narendra, but could be anyone
in the future once Narendra is promoted or changes responsibilities
(or even employers).

-Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
