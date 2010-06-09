From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Wed, 9 Jun 2010 08:02:40 -0700
Message-ID: <20100609150240.GA20705@kroah.com>
References: <20100528115520.GA24114@littleblue.us.dell.com>
 <20100528154041.GA27186@kroah.com>
 <20100528181100.GA12806@auslistsprd01.us.dell.com>
 <20100528222745.GA28678@kroah.com>
 <20100529045140.GA22563@mdomsch-pws380.aus.amer.dell.com>
 <20100609041709.GA7280@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@Dell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@Dell.com>
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:46137 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756082Ab0FIPIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 11:08:38 -0400
Content-Disposition: inline
In-Reply-To: <20100609041709.GA7280@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 11:17:09PM -0500, Matt Domsch wrote:
> On Fri, May 28, 2010 at 11:51:40PM -0500, Domsch, Matt wrote:
> > On Fri, May 28, 2010 at 05:27:45PM -0500, Greg KH wrote:
> > > Care to post that ECN publically?  And no, the Linux Foundation does not
> > > have a PCI-SIG membership, the PCI-SIG keeps forbidding it.  Other
> > > operating systems are allowed to join but not Linux.  Strange but
> > > true...
> > 
> > I'm looking into it, and should know more next week.
> 
> I'm advised that I cannot post the ECN publically, due to it being an
> in-progress work item of a SIG working group, and therefore falls
> under the confidentiality rules that SIG members agree to.  Members of
> the PCI SIG have access, which unfortunately is not everyone.

Then we can't properly review this, sorry.  How about waiting until the
ECN is finalized?  Then we could review and possibly accept this.

thanks,

greg k-h
