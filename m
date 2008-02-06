From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 02/04]: cls_flow: fix key mask validity check
Date: Tue, 05 Feb 2008 16:20:07 -0800 (PST)
Message-ID: <20080205.162007.44787263.davem@davemloft.net>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
	<20080205142904.13543.34586.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759377AbYBFATi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 19:19:38 -0500
In-Reply-To: <20080205142904.13543.34586.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Feb 2008 15:29:41 +0100 (MET)

> [NET_SCHED]: cls_flow: fix key mask validity check
> 
> Since we're using fls(), we need to check whether the value is non-zero first.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
