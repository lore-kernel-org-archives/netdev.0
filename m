From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Fix usage of second flags bitmap
 when using LRO/RSC
Date: Thu, 30 Jul 2009 19:29:05 -0700 (PDT)
Message-ID: <20090730.192905.187916879.davem@davemloft.net>
References: <20090730222501.26121.2952.stgit@localhost.localdomain>
	<20090730222528.26121.30521.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37769
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbZGaC25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 22:28:57 -0400
In-Reply-To: <20090730222528.26121.30521.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Jul 2009 15:25:28 -0700

> A second set of feature flag bits was added, and the hardware RSC engine
> flags were moved there.  However, the code itself didn't make the move
> completely to use the new bitmap.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
