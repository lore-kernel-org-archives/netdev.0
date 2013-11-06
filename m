From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 1/2] net: Add layer 2 hardware acceleration
 operations for macvlan devices
Date: Wed, 06 Nov 2013 03:01:57 -0500 (EST)
Message-ID: <20131106.030157.1483150214352909742.davem@davemloft.net>
References: <20131105232443.5400.97238.stgit@jf-dev1-dcblab>
	<20131105233011.5400.23253.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, alexander.h.duyck@intel.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209Ab3KFICD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 03:02:03 -0500
In-Reply-To: <20131105233011.5400.23253.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 05 Nov 2013 15:30:12 -0800

> +		 /* If we get a NULL pointer back, or if we get an error
> +		  * then we should just fall through to the non accelerated path
> +		  */

Strange indentation here, two TABs and one SPACE instead of just two
TABs.  Please fix, thanks.
