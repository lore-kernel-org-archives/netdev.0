From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Wed, 13 Oct 2010 14:25:36 -0700 (PDT)
Message-ID: <20101013.142536.193720419.davem@davemloft.net>
References: <20101009.092043.58419374.davem@davemloft.net>
	<20101009103136.341104c5@nehalam>
	<4CB5BCD6.4000906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093Ab0JMVZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:25:15 -0400
In-Reply-To: <4CB5BCD6.4000906@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Wed, 13 Oct 2010 11:06:14 -0300

> Just to clarify, this patch that started this thead is not invalidated
> by this "problem". So, I'd like to see this patch committed on your
> tree. Does it make sense?

Yep, I've added the fix to net-2.6, thanks.
