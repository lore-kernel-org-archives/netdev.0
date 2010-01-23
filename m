From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/7] ixgbevf: Take action when the PF
 notifies the VF it is resetting.
Date: Sat, 23 Jan 2010 01:14:38 -0800 (PST)
Message-ID: <20100123.011438.237205627.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
	<20100123084658.9865.8972.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0AWJO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:27 -0500
In-Reply-To: <20100123084658.9865.8972.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:47:00 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> When the VF driver gets a control message from the PF that indicates the
> PF is about to reset or go down we schedule the watchdog timer so that
> it will detect the PF has gone offline and take appropriate action.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

