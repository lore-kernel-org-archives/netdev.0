From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc911x: register irq with device name, not
 driver name
Date: Sun, 11 Jan 2009 00:14:59 -0800 (PST)
Message-ID: <20090111.001459.141684232.davem@davemloft.net>
References: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
	<1231594169-24988-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbZAKIO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:14:59 -0500
In-Reply-To: <1231594169-24988-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Sat, 10 Jan 2009 13:29:29 +0000

> This change lets "cat /proc/interrupts" show the name of the ethernet
> device (e.g. eth0) rather than the driver name (smsc911x).
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Also applied, thanks Steve.
