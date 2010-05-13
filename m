From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 06/12] e1000e: Remove EN_MAC_ADDR_FILTER
 check from enable_mng_pass_thru check
Date: Wed, 12 May 2010 23:32:10 -0700 (PDT)
Message-ID: <20100512.233210.115941229.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010048.30827.12737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753996Ab0EMGcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:02 -0400
In-Reply-To: <20100511010048.30827.12737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:00:50 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Patch addresses issues when manageability passthrough is enabled, but the
> MAC_ADDR_FILTER bit is not set in the MANC register.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
