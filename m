From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/7] ixgbe: Remove unused emulation MAC
 storage from the per VF data structure.
Date: Sat, 23 Jan 2010 01:14:23 -0800 (PST)
Message-ID: <20100123.011423.20901562.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
	<20100123084601.9865.89876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51046
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752731Ab0AWJOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:11 -0500
In-Reply-To: <20100123084601.9865.89876.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:46:02 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> This data storage for SW emulated MAC addresses is unlikely to ever be used
> so pull it.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
