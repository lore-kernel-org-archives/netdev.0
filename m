From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: move rx queue RSC configuration to
 a separate function
Date: Mon, 21 Sep 2009 22:37:51 -0700 (PDT)
Message-ID: <20090921.223751.51303407.davem@davemloft.net>
References: <20090918194533.28898.49436.stgit@localhost.localdomain>
	<20090918194627.28898.75773.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754896AbZIVFhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:37:33 -0400
In-Reply-To: <20090918194627.28898.75773.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Sep 2009 12:46:27 -0700

> From: Nelson, Shannon <shannon.nelson@intel.com>
> 
> Shorten ixgbe_configure_rx() and lessen indent depth.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
