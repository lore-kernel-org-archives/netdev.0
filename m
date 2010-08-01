From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ingress filter message limit
Date: Sun, 01 Aug 2010 00:33:32 -0700 (PDT)
Message-ID: <20100801.003332.233698512.davem@davemloft.net>
References: <20100731121316.1adb52c0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751425Ab0HAHdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Aug 2010 03:33:14 -0400
In-Reply-To: <20100731121316.1adb52c0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 31 Jul 2010 12:13:16 -0700

> If user misconfigures ingress and causes a redirection loop, don't
> overwhelm the log.  This is also a error case so make it unlikely.
> Found by inspection, luckily not in real system.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
