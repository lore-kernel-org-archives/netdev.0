From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/33] netdev: expose ethernet address primitives
Date: Wed, 19 Nov 2008 21:45:25 -0800 (PST)
Message-ID: <20081119.214525.237105966.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234355.032625967@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbYKTFp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:45:26 -0500
In-Reply-To: <20081117234355.032625967@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:10 -0800

> When ethernet devices are converted, the function pointer setup
> by eth_setup() need to be done during intialization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
