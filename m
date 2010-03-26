From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Priority tag FIP frames
Date: Fri, 26 Mar 2010 11:58:30 -0700 (PDT)
Message-ID: <20100326.115830.13275287.davem@davemloft.net>
References: <20100324224500.6653.28216.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, robert.w.love@intel.com,
	christopher.leech@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753224Ab0CZS6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:58:07 -0400
In-Reply-To: <20100324224500.6653.28216.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 15:45:00 -0700

> From: Robert Love <robert.w.love@intel.com>
> 
> Currently FIP (FCoE Initialization Protocol) frames
> are going untagged. This causes various problems
> with FCFs (switches) that have negotiated a priority
> over dcbx. This patch tags FIP frames with the same
> priority as the FCoE frames.
> 
> Signed-off-by: Robert Love <robert.w.love@intel.com>
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
