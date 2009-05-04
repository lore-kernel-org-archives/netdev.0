From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic"
 tryingtoifenslave a second interface to my bond
Date: Mon, 04 May 2009 16:04:42 -0700 (PDT)
Message-ID: <20090504.160442.201120049.davem@davemloft.net>
References: <4086.1241463817@death.nxdomain.ibm.com>
	<20090504.120651.32573620.davem@davemloft.net>
	<15291.1241478051@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@mad-scientist.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754590AbZEDXEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 19:04:48 -0400
In-Reply-To: <15291.1241478051@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 04 May 2009 16:00:51 -0700

> 	Regardless of the -stable situation, the patch is still needed
> for the current mainline (sorry if that wasn't clear).  I checked it
> against the current net-2.6 and net-next-2.6 trees, and it should apply
> to either one.

I didn't realize that, ok I'll unmark it in patchwork and
get to it soon.

Thanks.
