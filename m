From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/77] infiniband: convert nes driver to net_device_ops
Date: Sat, 21 Mar 2009 19:34:20 -0700 (PDT)
Message-ID: <20090321.193420.211698588.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053712.868239443@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: faisal.latif@intel.com, chien.tin.tung@intel.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45549
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752842AbZCVCec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:34:32 -0400
In-Reply-To: <20090321053712.868239443@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:35:31 -0700

> Also, removed unnecessary memset() sinc alloc_netdev returns
> zeroed memory.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
