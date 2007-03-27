From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: sch_htb/sch_hfsc: fix oops in qlen_notify
Date: Tue, 27 Mar 2007 14:04:40 -0700 (PDT)
Message-ID: <20070327.140440.133168590.davem@davemloft.net>
References: <46094640.7010806@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965417AbXC0VEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:04:41 -0400
In-Reply-To: <46094640.7010806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 27 Mar 2007 18:28:48 +0200

> Fix fallout from my qdisc endless loop fixes. I've checked
> all qdiscs, these two should be the only broken ones.
> The patch applies to current -git and the last -stable.

Applied, thanks Patrick.
