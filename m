From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: fix non-const printk argument
Date: Sat, 21 Mar 2009 19:09:00 -0700 (PDT)
Message-ID: <20090321.190900.225240101.davem@davemloft.net>
References: <20090320094402.5bf234b3@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752855AbZCVCJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:09:13 -0400
In-Reply-To: <20090320094402.5bf234b3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 09:44:02 -0700

> Change printk() argument to fix compiler warning.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
