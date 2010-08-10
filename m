From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: sch_sfq: Add dummy unbind_tcf and put
 handles. Was: [PATCH] sfq: add dummy bind/unbind handles
Date: Tue, 10 Aug 2010 01:41:38 -0700 (PDT)
Message-ID: <20100810.014138.229735037.davem@davemloft.net>
References: <20100809221817.GA18629@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: franchoze@yandex.ru, shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416Ab0HJIlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:41:19 -0400
In-Reply-To: <20100809221817.GA18629@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 10 Aug 2010 00:18:17 +0200

> Add dummy .unbind_tcf and .put qdisc class ops for easier verification.
> (All other schedulers have it like this.)
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
