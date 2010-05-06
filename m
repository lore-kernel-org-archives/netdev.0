From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/4] e1000e: Save irq into netdev structure
Date: Thu, 06 May 2010 00:19:53 -0700 (PDT)
Message-ID: <20100506.001953.02282932.davem@davemloft.net>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
	<20100506000330.8042.91540.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, therbert@google.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47769
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754846Ab0EFHTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:19:46 -0400
In-Reply-To: <20100506000330.8042.91540.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 17:03:32 -0700

> From: Tom Herbert <therbert@google.com>
> 
> Set net->devirq to pdev->irq.  This should be consistent with other
> drivers.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
