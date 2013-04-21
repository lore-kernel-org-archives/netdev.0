From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/14] pci: Add SRIOV helper function to determine
 if VFs are assigned to guest
Date: Sat, 20 Apr 2013 20:54:33 -0400 (EDT)
Message-ID: <20130420.205433.708823422668407918.davem@davemloft.net>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1366451353-24714-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab3DUAyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 20:54:37 -0400
In-Reply-To: <1366451353-24714-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 20 Apr 2013 02:49:07 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This function is meant to add a helper function that will determine if a PF
> has any VFs that are currently assigned to a guest.  We currently have been
> implementing this function per driver, and going forward I would like to avoid
> that by making this function generic and using this helper.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I will need a signoff on this from one of the PCI maintainers.
