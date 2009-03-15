From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: remove ASPM L0s workaround
Date: Sat, 14 Mar 2009 22:26:58 -0700 (PDT)
Message-ID: <20090314.222658.147980177.davem@davemloft.net>
References: <20090315013846.23201.71757.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751357AbZCOF1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 01:27:12 -0400
In-Reply-To: <20090315013846.23201.71757.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 Mar 2009 18:38:52 -0700

> The L0s workaround should be moved into a pci quirk and so it is not
> necessary in the driver.  This update removes the L0s workaround from the
> igb driver.
> 
> This was the second half of the PCI quirk patch that Matthew Wilcox did
> not pick up when he picked up the quirk patch.
> 
> This patch applies to the net-2.6 tree. :)
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
