From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] e1000e: provide MAC-family-specific
 function to set LAN ID
Date: Wed, 13 Jan 2010 20:32:11 -0800 (PST)
Message-ID: <20100113.203211.72999599.davem@davemloft.net>
References: <20100113120416.23715.64354.stgit@localhost.localdomain>
	<20100113120516.23715.960.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754541Ab0ANEcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:32:02 -0500
In-Reply-To: <20100113120516.23715.960.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 04:05:18 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Provide MAC-specific function pointer to determine the LAN ID (PCI func).
> The LAN ID is used internally by the driver to determine which h/w lock
> to use to protect accessing the PHY on ESB2 as well as help to determine
> the alternate MAC address on some parts.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
