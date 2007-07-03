From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 03/04]: sch_htb: use generic estimator
Date: Mon, 02 Jul 2007 22:48:26 -0700 (PDT)
Message-ID: <20070702.224826.08672034.davem@davemloft.net>
References: <20070619150203.30997.79383.sendpatchset@localhost.localdomain>
	<166fe7950706191107p2563af77w9b1038dc216925f@mail.gmail.com>
	<467848FE.7090106@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ranjitm@google.com, devik@cdi.cz, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751264AbXGCFsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:48:06 -0400
In-Reply-To: <467848FE.7090106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 19 Jun 2007 23:22:06 +0200

> [NET_SCHED]: sch_htb: use generic estimator
> 
> Use the generic estimator instead of reimplementing (parts of) it.
> For compatibility always create a default estimator for new classes.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
