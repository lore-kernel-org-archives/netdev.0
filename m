From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: set the correct DCB bit for pg tx
 settings
Date: Thu, 28 Jan 2010 05:56:57 -0800 (PST)
Message-ID: <20100128.055657.230868271.davem@davemloft.net>
References: <20100128023717.19441.27328.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754650Ab0A1N4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:56:46 -0500
In-Reply-To: <20100128023717.19441.27328.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Jan 2010 18:37:44 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Set the correct bit BIT_PG_TX when tx PG settings are set.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
