From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to
 drvinfo and return it
Date: Fri, 26 Feb 2010 04:20:27 -0800 (PST)
Message-ID: <20100226.042027.250812962.davem@davemloft.net>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935868Ab0BZMUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:20:09 -0500
In-Reply-To: <20100226115355.20213.59254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 03:54:20 -0800

> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> The drvinfo struct should include the number of strings that
> get_rx_ntuple will return.  It will be variable if an underlying
> driver implements its own get_rx_ntuple routine, so userspace
> needs to know how much data is coming.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
