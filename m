From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] ixgbe: Add boolean parameter to
 ixgbe_set_vmolr
Date: Thu, 06 May 2010 00:25:32 -0700 (PDT)
Message-ID: <20100506.002532.98883052.davem@davemloft.net>
References: <20100505081129.5709.39430.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57048
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754627Ab0EFHZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:25:25 -0400
In-Reply-To: <20100505081129.5709.39430.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 01:11:46 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add a boolean parameter to ixgbe-set_vmolr so that the caller can
> specify whether the pool should accept untagged packets.  Required
> for a follow on patch to enable administrative configuration of port
> VLAN for virtual functions.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
