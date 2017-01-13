From: Christoph Hellwig <hch@lst.de>
Subject: Re: kill off pci_enable_msi_{exact,range}
Date: Fri, 13 Jan 2017 08:55:03 +0100
Message-ID: <20170113075503.GA26014@lst.de>
References: <1483994260-19797-1-git-send-email-hch@lst.de> <20170112212900.GE8312@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, linux-pci@vger.kernel.org,
        Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org,
        Tom Lendacky <thomas.lendacky@amd.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170112212900.GE8312@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 03:29:00PM -0600, Bjorn Helgaas wrote:
> Applied all three (with Tom's ack on the amd-xgbe patch) to pci/msi for
> v4.11, thanks!

Tom had just send me an event better version of the xgbe patch.  Tom,
maybe you can resend that relative to the PCI tree [1], so that we don't
lose it for next merge window?

[1] https://git.kernel.org/cgit/linux/kernel/git/helgaas/pci.git)
