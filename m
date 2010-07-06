From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: use netif_<level> instead of
 netdev_<level>
Date: Mon, 05 Jul 2010 19:09:00 -0700 (PDT)
Message-ID: <20100705.190900.98868373.davem@davemloft.net>
References: <20100702060508.17100.39352.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	joe@perches.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53032
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757422Ab0GFCIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:08:46 -0400
In-Reply-To: <20100702060508.17100.39352.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 23:05:12 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch restores the ability to set msglvl through ethtool.
> The issue was introduced by:
> commit 849c45423c0c108e08d67644728cc9b0ed225fa1
> 
> CC: Joe Perches <joe@perches.com>
> 
> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
