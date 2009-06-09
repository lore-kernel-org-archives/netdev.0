From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgbe: Include offloaded FCoE data into total
 rx/tx statistics for 82599
Date: Tue, 09 Jun 2009 05:21:17 -0700 (PDT)
Message-ID: <20090609.052117.245948998.davem@davemloft.net>
References: <20090609003844.5208.72539.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755051AbZFIMVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:21:14 -0400
In-Reply-To: <20090609003844.5208.72539.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 08 Jun 2009 17:38:44 -0700

> Include offloaded FCoE data into total rx/tx statistics for 82599 so they
> are properly reflected by ethtool or ifconfig.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
