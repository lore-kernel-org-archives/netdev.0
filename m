From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFT] convert syskonnect gigabit ether driver to PCI module interface
Date: Tue, 22 Jun 2004 19:23:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D8BF63.9010308@pobox.com>
References: <20040622161130.0adaac78@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlinder@syskonnect.de>,
        Ralph Roesler <rroesler@syskonnect.de>, netdev@oss.sgi.com,
        Christoph Hellwig <hch@lst.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040622161130.0adaac78@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch converts the SysKonnect Gigabit Ethernet (Yukon) driver from
> the old pci_find_class infrastructure, to the current 2.4/2.6 pci_module probing
> model.  The device identification is no longer done in the macro, but in a pci_device_id
> table like other drivers.


Didn't Christoph just submit this same patch?  :)

	Jeff
