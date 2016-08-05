From: Adit Ranadive <aditr@vmware.com>
Subject: RE: [PATCH] vmxnet3: Move PCI Id to pci_ids.h
Date: Fri, 5 Aug 2016 21:22:16 +0000
Message-ID: <BLUPR0501MB836F0E58C62EB35F561E4D4C5180@BLUPR0501MB836.namprd05.prod.outlook.com>
References: <1470420039-23125-1-git-send-email-aditr@vmware.com>
 <20160805182332.GA6369@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shrikrishna Khare <skhare@vmware.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	pv-drivers <pv-drivers@mailman2.vmware.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"leon@kernel.org" <leon@kernel.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:11677 "EHLO
	EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S3002616AbcHEVxg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 17:53:36 -0400
In-Reply-To: <20160805182332.GA6369@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 05, 2016 11:23:41AM -0700, Bjorn Helgaas <helgaas@kernel.org> wrote:
> On Fri, Aug 05, 2016 at 11:00:39AM -0700, Adit Ranadive wrote:
> > The VMXNet3 PCI Id will be shared with our upcoming paravirtual RDMA
> > driver. Moved it to the shared location in pci_ids.h and updated the
> > driver version.
> >
> > Suggested-by: Leon Romanovsky <leon@kernel.org>
> > Signed-off-by: Adit Ranadive <aditr@vmware.com>
> 
> Please include this in the series that adds your paravirtual RDMA
> driver.  Please do not change the driver version information in this
> patch, because that change is unrelated to moving the PCI ID.

Ok, I will. Please drop this patch then.

Thanks,
Adit
