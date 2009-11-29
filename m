From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] ixgbe: LINKS2 is not a valid register
 for 82598
Date: Sun, 29 Nov 2009 00:34:52 -0800 (PST)
Message-ID: <20091129.003452.226753193.davem@davemloft.net>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
	<20091125045147.23932.39966.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753328AbZK2Ier (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:34:47 -0500
In-Reply-To: <20091125045147.23932.39966.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Nov 2009 20:51:48 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> 82598 shouldn't try and access LINKS2 while configuring
> link and flow control.  This is an 82599-only register.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
