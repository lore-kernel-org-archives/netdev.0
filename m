From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: Fix the DCB PFC thresholds for 82599
Date: Fri, 17 Apr 2009 01:17:59 -0700 (PDT)
Message-ID: <20090417.011759.266639195.davem@davemloft.net>
References: <20090417010019.19018.62374.stgit@localhost.localdomain>
	<20090417010041.19018.76862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757052AbZDQISI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:18:08 -0400
In-Reply-To: <20090417010041.19018.76862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Apr 2009 18:00:41 -0700

> The thresholds for the DCB priority flow control are incorrect for 82599.
> This fixes the thresholds to be correct.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
