From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/5] igb: Add comment
Date: Thu, 01 Jul 2010 22:50:20 -0700 (PDT)
Message-ID: <20100701.225020.00467172.davem@davemloft.net>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
	<20100701233921.16171.58140.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754798Ab0GBFuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:50:06 -0400
In-Reply-To: <20100701233921.16171.58140.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:39:23 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add explanatory comment to avoid confusion when a pointer is set
> to the second word of an array instead of the customary cast of a
> pointer to the beginning of the array.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
