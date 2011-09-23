From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been assigned
 by KVM
Date: Fri, 23 Sep 2011 15:05:37 -0400
Message-ID: <20110923190537.GA18850@phenom.oracle.com>
References: <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
 <1316762872.23371.88.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
 <20110923180025.GA6251@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:41823 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1IWTPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 15:15:35 -0400
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Version 2 of this patch with the modified comment was just posted to
> > netdev.  Ian Campbell had mentioned that the Xen pciback driver should be
> > modified to use this flag but I don't believe any patches for it have been
> > created yet.
> > 
> > http://marc.info/?i=20110729165446.GA6731@dumpdata.com
> > 
> 
> I'm not sure who generated the patches to xen-pciback.  It wasn't me and I couldn't tell from the links you provided who did generate that patch.  I don't see it now though.

I provided it.

And I asked for a git tree so I could double check that it actually
worked as I don't have the full set of your patches.

Can you provide me a link to your public git tree or just repost it once more?
> 
> - Greg
