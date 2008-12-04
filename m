From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: sch_htb: Clean htb_class prio and
 quantum fields
Date: Wed, 03 Dec 2008 21:09:54 -0800 (PST)
Message-ID: <20081203.210954.222390471.davem@davemloft.net>
References: <20081202085648.GC10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39529
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751366AbYLDFJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 00:09:53 -0500
In-Reply-To: <20081202085648.GC10412@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 2 Dec 2008 08:56:48 +0000

> While implementing htb_parent_to_leaf() there where added backup prio
> and quantum struct htb_class fields to preserve these values for inner
> classes in case of their return to leaf. This patch cleans this a bit
> by removing union leaf duplicates.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Also applied, thanks Jarek.
