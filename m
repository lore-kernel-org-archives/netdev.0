From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000: use netif_<level> instead of
 netdev_<level>
Date: Mon, 26 Jul 2010 23:38:05 -0700 (PDT)
Message-ID: <20100726.233805.45906789.davem@davemloft.net>
References: <20100727063129.24362.20955.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	joe@perches.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750908Ab0G0Ght (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 02:37:49 -0400
In-Reply-To: <20100727063129.24362.20955.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Jul 2010 23:33:31 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch restores the ability to set msglvl through ethtool.
> The issue was introduced by:
> commit 675ad47375c76a7c3be4ace9554d92cd55518ced
> 
> CC: Joe Perches <joe@perches.com>
> 
> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
