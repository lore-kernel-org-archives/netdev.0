From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: return IXGBE_ERR_RAR_INDEX when out of
 range
Date: Thu, 03 Jun 2010 03:29:56 -0700 (PDT)
Message-ID: <20100603.032956.160069854.davem@davemloft.net>
References: <20100602224405.13236.13183.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, xma@us.ibm.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCK3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:46 -0400
In-Reply-To: <20100602224405.13236.13183.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 02 Jun 2010 15:44:05 -0700

> Based on original patch from Shirley Ma <xma@us.ibm.com>
> Return IXGBE_ERR_RAR_INDEX when RAR index is out of range, instead of
> returning IXGBE_SUCCESS.
> 
> CC: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>

Applied.
