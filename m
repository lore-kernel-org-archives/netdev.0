From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/10] IPV4: use rcu to walk list of devices in IGMP
Date: Tue, 10 Nov 2009 22:50:09 -0800 (PST)
Message-ID: <20091110.225009.40183374.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.754389168@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753363AbZKKGtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:49:42 -0500
In-Reply-To: <20091110175647.754389168@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Nov 2009 09:54:55 -0800

> This also needs to be optimized for large number of devices.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
