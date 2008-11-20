From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/33] sky2: convert to net_device_ops
Date: Wed, 19 Nov 2008 22:00:01 -0800 (PST)
Message-ID: <20081119.220001.223689748.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234355.977815463@vyatta.com>
	<20081117173752.426782b8@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbYKTGAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:00:01 -0500
In-Reply-To: <20081117173752.426782b8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 17:37:52 -0800

> Convert to new network device ops interface. Slight additional complexity
> here because the second port does not allow netpoll and therefore has
> different virtual function table.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Handle non-vlan build.

Applied.
