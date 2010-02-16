From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ethtool: Move n-tuple capability
 check into set_flags
Date: Mon, 15 Feb 2010 21:52:51 -0800 (PST)
Message-ID: <20100215.215251.197242572.davem@davemloft.net>
References: <20100212234715.2346.60380.stgit@localhost.localdomain>
	<20100212234823.2346.32285.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807Ab0BPFwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:52:36 -0500
In-Reply-To: <20100212234823.2346.32285.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Feb 2010 15:48:25 -0800

> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> set_flags should check if the underlying device supports
> n-tuple filter programming before setting the device flags
> on the netdevice.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
