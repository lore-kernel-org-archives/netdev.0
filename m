From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: allow VLAN devices to use TSO and CSUM offload
Date: Sat, 11 Oct 2008 12:26:58 -0700 (PDT)
Message-ID: <20081011.122658.255173670.davem@davemloft.net>
References: <20081011013458.11804.35278.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759621AbYJKT1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 15:27:22 -0400
In-Reply-To: <20081011013458.11804.35278.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Oct 2008 18:34:58 -0700

> From: Patrick McHardy <kaber@trash.net>
> 
> This patch changes e1000 to set vlan_features so TSO and CSUM
> offload can be used by VLAN devices, similar as with the other
> Intel drivers.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-2.6, thanks.

I'm applying this because Patrick submitted this a long time
ago in the same form that it had in this final submission.

