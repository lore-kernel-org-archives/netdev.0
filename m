From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: define feature flags for FCoE offloads
Date: Wed, 19 Nov 2008 17:18:10 -0800 (PST)
Message-ID: <20081119.171810.102832831.davem@davemloft.net>
References: <20081119.154710.135220757.davem@davemloft.net>
	<1DB50624F8348F48840F2E2CF6040A9D2F383FB5@orsmsx508.amr.corp.intel.com>
	<20081119.171426.197284550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752506AbYKTBSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 20:18:10 -0500
In-Reply-To: <20081119.171426.197284550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 19 Nov 2008 17:14:26 -0800 (PST)

BTW, the netdev address has been wrong this entire time, it's
"netdev" not "linux-netdev".  Fixed.

> From: "Zou, Yi" <yi.zou@intel.com>
> Date: Wed, 19 Nov 2008 16:02:03 -0800
> 
> > Thanks for reviewing the patch. I am hoping to make use of the
> > existing gso logic as much as possible for fcoe segmentation as
> > well, to hookup fcoe segmentation using ptype->gso_segment().
> 
> There is no way for anyone to evaluate this usage and determine
> whether it makes sense or not until you post those patches.
