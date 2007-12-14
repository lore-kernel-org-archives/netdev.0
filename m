From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] PPP synchronous tty: convert dead_sem to completion
Date: Fri, 14 Dec 2007 11:33:00 -0800 (PST)
Message-ID: <20071214.113300.267654211.davem@davemloft.net>
References: <200712140002.lBE02cF7025497@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthias.kaehlcke@gmail.com,
	paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765572AbXLNTdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:33:09 -0500
In-Reply-To: <200712140002.lBE02cF7025497@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 13 Dec 2007 16:02:37 -0800

> From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> 
> PPP synchronous tty channel driver: convert the semaphore dead_sem to a
> completion
> 
> Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.25, thanks.
