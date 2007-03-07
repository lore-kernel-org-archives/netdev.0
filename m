From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP Yeah: cleanup
Date: Tue, 06 Mar 2007 20:21:40 -0800 (PST)
Message-ID: <20070306.202140.36924635.davem@davemloft.net>
References: <45D97FEA.1080006@gmail.com>
	<45D98084.5030907@gmail.com>
	<20070306145605.3731d39d@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani@gmail.com, netdev@vger.kernel.org,
	andrea.baiocchi@uniroma1.it, francesco@net.infocom.uniroma1.it
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161315AbXCGEVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:21:42 -0500
In-Reply-To: <20070306145605.3731d39d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 6 Mar 2007 14:56:05 -0800

> 
> Eliminate need for full 6/4/64 divide to compute queue.
> Variable maxqueue was really a constant.
> Fix indentation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
