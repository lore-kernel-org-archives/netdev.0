From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: cleanup ethtool autoneg input
Date: Tue, 27 Apr 2010 14:36:09 -0700 (PDT)
Message-ID: <20100427.143609.25134196.davem@davemloft.net>
References: <20100427213002.25913.93796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754077Ab0D0VgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:36:03 -0400
In-Reply-To: <20100427213002.25913.93796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 14:31:06 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> The way we were setting autoneg via ethtool was inconstant with that
> of our other drivers.  It will change the following:
...
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
