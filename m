From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/7] ixgbe: fix wrong offset to
 fc_frame_header in ixgbe_fcoe_ddp
Date: Tue, 18 May 2010 19:44:38 -0700 (PDT)
Message-ID: <20100518.194438.37554835.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
	<20100519020005.18654.75760.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753225Ab0ESCoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:30 -0400
In-Reply-To: <20100519020005.18654.75760.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:05 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Make sure we point to the right offset of the fc_frame_header when
> VLAN header exists and HW has VLAN stripping disabled.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
