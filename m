From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] ixgbe: fix IXGBE_MTQC values
Date: Sat, 11 Apr 2009 02:50:07 -0700 (PDT)
Message-ID: <20090411.025007.83469513.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082639.14372.29299.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757321AbZDKJuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:50:17 -0400
In-Reply-To: <20090410082639.14372.29299.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:26:40 -0700

> IXGBE_MTQC_64VF was wrong and 32VF not defined at all.  This patch
> corrects that.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
