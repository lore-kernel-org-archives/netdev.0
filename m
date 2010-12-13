From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: clean up twisted goto in
 tcp_rcv_synsent_state_process()
Date: Mon, 13 Dec 2010 09:42:02 -0800 (PST)
Message-ID: <20101213.094202.193731360.davem@davemloft.net>
References: <20101213171149.16f178ef.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yuasa@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757859Ab0LMRle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:41:34 -0500
In-Reply-To: <20101213171149.16f178ef.yuasa@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yuasa@linux-mips.org>
Date: Mon, 13 Dec 2010 17:11:49 +0900

> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>

I've been reading this stretch of code for 5+ years and it's
perfectly readable to me and your version is not any more
readable than what's there now.

I'm not applying this, sorry.
