From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH 01/34] bnx2: Use pci_enable_msix_range()
Date: Tue, 11 Feb 2014 09:01:28 +0100
Message-ID: <20140211080128.GB16680@dhcp-26-207.brq.redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
 <434a34e01c353441131204edef36126a95e8928a.1391172839.git.agordeev@redhat.com>
 <20140131.133051.483295479425700960.davem@davemloft.net>
 <20140211003814.GC12851@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	mchan@broadcom.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140211003814.GC12851@google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 05:38:14PM -0700, Bjorn Helgaas wrote:
> I *think* this whole series applies to drivers/net (the usual patch sending
> tools like "stg mail" insert the diffstat automatically in the 00/nn
> message), and it sounds like David is willing to apply them via his tree,
> so I'm ignoring these for now.  Let me know if you need me to do anything.

Hi Bjorn,

Unlike just a handful of patches concerning pci_enable_msi_range(), some
few dozens of pci_enable_msix_range() updates would be difficult to route
thru your tree. So for net and scsi (and block is pending) I am putting
linux-pci on CC just to let you know what is happening.

> Bjorn

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
