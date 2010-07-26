From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V3] Export SMBIOS provided firmware instance and label
 to sysfs
Date: Mon, 26 Jul 2010 11:20:19 -0700
Message-ID: <20100726182019.GA5144@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612C40@blrx3m08.blr.amer.dell.com>
 <20100723133456.GA9378@auslistsprd01.us.dell.com>
 <20100723135557.GA3624@kroah.com>
 <20100723145809.GA7629@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <Narendra_K@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100723145809.GA7629@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 09:58:09AM -0500, Matt Domsch wrote:
> On Fri, Jul 23, 2010 at 06:55:57AM -0700, Greg KH wrote:
> > On Fri, Jul 23, 2010 at 08:34:56AM -0500, Narendra K wrote:
> > > --- a/Documentation/ABI/testing/sysfs-bus-pci
> > > +++ b/Documentation/ABI/testing/sysfs-bus-pci
> > > @@ -179,3 +179,30 @@ Contact:	linux-pci@vger.kernel.org
> > >  Description:
> > >  		This symbolic link points to the PCI hotplug controller driver
> > >  		module that manages the hotplug slot.
> > > +
> > > +What:		/sys/bus/pci/devices/.../label
> > > +Date:		July 2010
> > > +Contact:	linux-bugs@dell.com
> > 
> > that's not your email address.  Please don't hide behind some random
> > address, Linux is about contacting developers directly were ever
> > possible.
> 
> That's actually the public email address for the whole Linux
> engineering team (including engineers and managers) at Dell, of which
> Narendra is a part.  It's the address we publish for people to include
> on the cc: list of bugzilla issues on the kernel.org, Novell, and Red
> Hat bugzillas.  This ensures someone on the team will see bug reports
> or patches and act accordingly, likely Narendra, but could be anyone
> in the future once Narendra is promoted or changes responsibilities
> (or even employers).

Ok, I don't really like it, but if that's what Dell wants to do, I guess
it's acceptable.

thanks,

greg k-h
