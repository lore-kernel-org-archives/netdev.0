From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Fix compiler warning about variable
 being used uninitialized
Date: Thu, 07 Jan 2010 17:27:38 -0800 (PST)
Message-ID: <20100107.172738.07027283.davem@davemloft.net>
References: <20100107035001.28341.55395.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752432Ab0AHB1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:27:30 -0500
In-Reply-To: <20100107035001.28341.55395.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jan 2010 19:50:29 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> tc is still throwing a warning that is could be used
> uninitialized.  This fixes it, and properly formats the device ID
> checks for the use of this variable.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
