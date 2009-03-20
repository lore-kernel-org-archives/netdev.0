From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] ixgbe: Correctly report Wake On LAN for
 82599 KX4 devices
Date: Fri, 20 Mar 2009 01:32:01 -0700 (PDT)
Message-ID: <20090320.013201.192420711.davem@davemloft.net>
References: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
	<20090319112346.11957.71479.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756274AbZCTIcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:32:14 -0400
In-Reply-To: <20090319112346.11957.71479.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:23:46 -0700

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> ethtool isn't reporting the support level of WoL for 82599 KX4 devices.
> While the device does support WoL, ethtool was never updated to properly
> report the level of support, nor will it allow ethtool to modify the type
> of packets to listen for.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
