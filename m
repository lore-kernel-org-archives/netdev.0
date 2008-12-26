From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/3] ixgbe: Fix NAPI enable/disable path when
 using DCB
Date: Fri, 26 Dec 2008 01:36:13 -0800 (PST)
Message-ID: <20081226.013613.07429840.davem@davemloft.net>
References: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
	<20081225090223.13754.9178.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753526AbYLZJgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:36:10 -0500
In-Reply-To: <20081225090223.13754.9178.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Dec 2008 01:02:23 -0800

> This change allows DCB mode to change the number of queues, and presumably
> the number of NAPI instances, safely.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
