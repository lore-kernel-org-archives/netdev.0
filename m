From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: Fix PCI bus reporting on driver
 load for 82598 after 82599 merge
Date: Fri, 20 Mar 2009 01:31:53 -0700 (PDT)
Message-ID: <20090320.013153.188027356.davem@davemloft.net>
References: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755847AbZCTIcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:32:06 -0400
In-Reply-To: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:23:29 -0700

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> 82598's PCI bus reporting on driver load was broken after 82599 merged.
> This results in incorrect reporting, and an erroneous warning message
> that the 82598 is in a PCIe slot that isn't fast enough to run 10GbE.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

APplied.
