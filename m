From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Wed, 27 Oct 2010 08:45:01 -0700 (PDT)
Message-ID: <20101027.084501.193727326.davem@davemloft.net>
References: <20101025223853.GD15074@solarflare.com>
	<20101025.162535.226782713.davem@davemloft.net>
	<1288075928.6578.185.camel@concordia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, somnath.kotur@emulex.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: michael@ellerman.id.au
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1288075928.6578.185.camel@concordia>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Oct 2010 17:52:08 +1100

> That horse has really really bolted, it's gawn.
> 
> I count 26 drivers with "disable MSI/X" parameters. Some even have more
> than one.
> 
> 11 of them are network drivers, 9 scsi, 3 ata.
> 
> I agree it's a mess for users, but it's probably preferable to a
> non-working driver.

Stupid inappropriate things being in the tree doesn't mean I need
to accept more of them.
