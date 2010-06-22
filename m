From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16268] New: kernel oops when rmmod the
 tcp_diag modules
Date: Tue, 22 Jun 2010 14:21:12 -0700 (PDT)
Message-ID: <20100622.142112.116387598.davem@davemloft.net>
References: <bug-16268-10286@https.bugzilla.kernel.org/>
	<20100622141232.4b8f1d4a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lyw@cn.fujitsu.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750809Ab0FVVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 17:20:59 -0400
In-Reply-To: <20100622141232.4b8f1d4a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 22 Jun 2010 14:12:32 -0700

> What is "ss"?  Something which triggers a load of kernel modules,
> presumably.  Which ones?

'ss' is the tool which dumps sockets using netlink
