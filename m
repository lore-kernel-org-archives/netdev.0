From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/33] cxgb2: convert to net_device_ops
Date: Wed, 19 Nov 2008 22:17:13 -0800 (PST)
Message-ID: <20081119.221713.81711774.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234356.667397719@vyatta.com>
	<20081117174020.3a888ff6@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751589AbYKTGRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:17:13 -0500
In-Reply-To: <20081117174020.3a888ff6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 17:40:20 -0800

> Convert this driver to network device ops. Compile teseted only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Need to handle non-vlan cas as well.

Applied.
