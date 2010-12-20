From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net_sched: sch_sfq: better struct layouts
Date: Mon, 20 Dec 2010 13:33:42 -0800 (PST)
Message-ID: <20101220.133342.246531313.davem@davemloft.net>
References: <1292604766.2906.51.camel@edumazet-laptop>
	<20101219212234.GA2323@del.dom.local>
	<1292864525.2800.189.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754457Ab0LTVdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 16:33:12 -0500
In-Reply-To: <1292864525.2800.189.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Dec 2010 18:02:05 +0100

> [PATCH v2] net_sched: sch_sfq: better struct layouts

Please respin this against current net-next-2.6, it doesn't
apply cleanly after your other two sfq changes.

Thanks!
