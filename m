From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v3 1/5] pci: Add SR-IOV convenience
 functions and macros
Date: Fri, 12 Feb 2010 16:56:32 -0800 (PST)
Message-ID: <20100212.165632.189691465.davem@davemloft.net>
References: <20100210114303.14483.71368.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757449Ab0BMA4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 19:56:18 -0500
In-Reply-To: <20100210114303.14483.71368.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 10 Feb 2010 03:43:04 -0800

> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> Add and export pci_num_vf to allow other subsystems to determine how many
> virtual function devices are associated with an SR-IOV physical function
> device.
> Add macros dev_is_pci, dev_is_ps, and dev_num_vf to make it easier for
> non-PCI specific code to determine SR-IOV capabilities.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
