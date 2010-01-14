From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] e1000e: genericize the update
 multicast address list
Date: Wed, 13 Jan 2010 20:32:16 -0800 (PST)
Message-ID: <20100113.203216.02579889.davem@davemloft.net>
References: <20100113120416.23715.64354.stgit@localhost.localdomain>
	<20100113120537.23715.75967.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754249Ab0ANEcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:32:07 -0500
In-Reply-To: <20100113120537.23715.75967.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 04:05:38 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Make updating the multicast address list generic for all families and
> enforce the requirement to update the entire multicast table array all at
> once instead of piecemeal which causes problems on some parts.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
