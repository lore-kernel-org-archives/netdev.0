From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] ixgbe: fix ethtool -A|a behavior
Date: Thu, 02 Apr 2009 01:16:09 -0700 (PDT)
Message-ID: <20090402.011609.66125852.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073505.3749.61750.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758553AbZDBIQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:16:20 -0400
In-Reply-To: <20090401073505.3749.61750.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:35:05 -0700

> We were basicly ignoring ethtool users request for FC autoneg
> and replying to queries with a "best guess".  This patch
> enables the driver to store if we want to enable/disable
> autoneg FC and do the correct behavior.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
