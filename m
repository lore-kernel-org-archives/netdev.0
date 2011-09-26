From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been assigned
 by KVM [and Xen]
Date: Mon, 26 Sep 2011 12:42:38 -0400
Message-ID: <20110926164238.GA4667@phenom.oracle.com>
References: <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
 <20110923180025.GA6251@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
 <20110923190537.GA18850@phenom.oracle.com>
 <1316839300.2182.134.camel@jtkirshe-mobl>
 <20110926162552.GA4175@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C5193AF@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ian Campbell <ijc@hellion.org.uk>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C5193AF@orsmsx508.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Any plans to support bnx4 and igb with this feature?
> 
> I'm updating the igb driver to support this feature right now.  I would hesitate to get into other drivers and muck with them because the changes to support this feature are not trivial and also involve policy decisions that I'd prefer to leave up to the folks who maintain those drivers.  Plus I have no other vendor hardware available to test the changes.
> 

Sounds fair. Did you CC them?

> > Any ETA?
> 
> I should have the igb driver work done in the next week or so.

Ok, please CC me on the code when you post it.
> 
> - Greg
