From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net_sched: add size table functions
Date: Sat, 05 Jul 2008 23:31:05 -0700 (PDT)
Message-ID: <20080705.233105.145299915.davem@davemloft.net>
References: <20080703220311.30053.63477.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751436AbYGFGbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:31:05 -0400
In-Reply-To: <20080703220311.30053.63477.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Fri, 04 Jul 2008 01:03:12 +0300

> Patch adds size table that is similiar to rate table, with difference that
> size table stores link layer packet size. It's needed for HFSC link
> layer adaption patch as it converts skb->len to link layer packet size
> directly, unlike HTB/CFQ/etc that convert packet length to link layer
> transfer time using rate tables.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Ok.

Patrick, can you give some feedback on these two patches?

Thanks!
