From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: add support for 82599 Combined
 Backplane
Date: Sun, 04 Oct 2009 21:08:55 -0700 (PDT)
Message-ID: <20091004.210855.101928818.davem@davemloft.net>
References: <20091002185803.8771.46655.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761AbZJEEJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 00:09:01 -0400
In-Reply-To: <20091002185803.8771.46655.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 02 Oct 2009 11:58:04 -0700

> This patch will add support for the 82599 Dual port Backplane
> device (0x10f8).  This device has the ability to link in serial (KR) and
> parallel (KX4/KX) modes, depending on what the switch capabilities are in
> the blade chassis.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
