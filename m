From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbevf: Shorten up delay timer for
 watchdog task
Date: Fri, 19 Mar 2010 21:06:18 -0700 (PDT)
Message-ID: <20100319.210618.104036564.davem@davemloft.net>
References: <20100319125950.9799.70157.stgit@localhost.localdomain>
	<20100319130011.9799.97156.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750772Ab0CTEF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:05:56 -0400
In-Reply-To: <20100319130011.9799.97156.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Mar 2010 06:00:12 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The recovery from PF reset works better when you shorten up the delay
> until the watchdog task executes.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
