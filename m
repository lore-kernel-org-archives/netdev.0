From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 23 Sep 2011 12:20:27 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C518E80@orsmsx508.amr.corp.intel.com>
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
 <20110923190537.GA18850@phenom.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110923190537.GA18850@phenom.oracle.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> Sent: Friday, September 23, 2011 12:06 PM
> To: Rose, Gregory V
> Cc: Kirsher, Jeffrey T; Ian Campbell; davem@davemloft.net; Jesse Barnes;
> netdev@vger.kernel.org; gospo@redhat.com; linux-pci@vger.kernel.org
> Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
> assigned by KVM
> 
> > > > Version 2 of this patch with the modified comment was just posted to
> > > netdev.  Ian Campbell had mentioned that the Xen pciback driver should
> be
> > > modified to use this flag but I don't believe any patches for it have
> been
> > > created yet.
> > >
> > > http://marc.info/?i=20110729165446.GA6731@dumpdata.com
> > >
> >
> > I'm not sure who generated the patches to xen-pciback.  It wasn't me and
> I couldn't tell from the links you provided who did generate that patch.
> I don't see it now though.
> 
> I provided it.
> 
> And I asked for a git tree so I could double check that it actually
> worked as I don't have the full set of your patches.
> 
> Can you provide me a link to your public git tree or just repost it once
> more?

Ah, I get it now.

Jeff Kirsher is the maintainer of our git trees.  Hopefully he'll come around and provide that info for you soon.

- Greg
