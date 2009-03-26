From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/4] e1000e: fix loss of multicast packets
Date: Thu, 26 Mar 2009 01:12:24 -0700 (PDT)
Message-ID: <20090326.011224.258744152.davem@davemloft.net>
References: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
	<20090326080520.30401.33149.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, daveboutcher@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756626AbZCZIMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:12:36 -0400
In-Reply-To: <20090326080520.30401.33149.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 01:05:21 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> e1000e (and e1000, igb, ixgbe, ixgb) all do a series of operations each
> time a multicast address is added.  The flow goes something like
 ...
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Dave Boutcher <daveboutcher@gmail.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
