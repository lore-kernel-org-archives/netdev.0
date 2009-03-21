From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: lec use dev_change_mtu
Date: Sat, 21 Mar 2009 13:37:47 -0700 (PDT)
Message-ID: <20090321.133747.261240938.davem@davemloft.net>
References: <20090319172400.239594f8@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbZCUUiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:38:00 -0400
In-Reply-To: <20090319172400.239594f8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Mar 2009 17:24:00 -0700

> Rather than calling device pointer directly (which is incorrect with
> net_device_ops), use the standard dev_change_mtu. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
