From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_probe: improvements for net-2.6.22
Date: Sat, 24 Mar 2007 21:35:54 -0700 (PDT)
Message-ID: <20070324.213554.38322269.davem@davemloft.net>
References: <20070323082438.52a728a2@mongrel>
	<5FBB64D9-2486-4600-9A36-441D8A7BF0C9@nuim.ie>
	<20070323134016.21581033@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: doug.leith@nuim.ie, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965180AbXCYEfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:35:55 -0400
In-Reply-To: <20070323134016.21581033@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 23 Mar 2007 13:40:16 -0700

> Change tcp_probe to use ktime (needed to add one export).
> Add option to only get events when cwnd changes - from Doug Leith
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Also applied, thanks Stephen.
