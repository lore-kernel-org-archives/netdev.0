From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 6/7] ixgbevf: Fix panics in the VF driver
Date: Sat, 23 Jan 2010 01:14:43 -0800 (PST)
Message-ID: <20100123.011443.230118267.davem@davemloft.net>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
	<20100123084717.9865.5467.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0AWJOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:14:32 -0500
In-Reply-To: <20100123084717.9865.5467.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:47:18 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Fix panics in the VF driver that occur when you bring it down after
> having already brought the PF down.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
