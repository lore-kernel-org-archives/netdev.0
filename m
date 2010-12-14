From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] workqueue: deprecate
 cancel_rearming_delayed_work[queue]()
Date: Tue, 14 Dec 2010 11:53:54 -0800 (PST)
Message-ID: <20101214.115354.104055630.davem@davemloft.net>
References: <4D078B6D.5060202@kernel.org>
	<4D078BDE.8060102@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	benh@kernel.crashing.org, mchehab@infradead.org,
	netdev@vger.kernel.org, cbou@mail.ru, dwmw2@infradead.org,
	zbr@ioremap.net, gregkh@suse.de, bfields@fieldses.org,
	neilb@suse.de, aelder@sgi.com, xfs-masters@oss.sgi.com,
	cl@linux-foundation.org, penberg@cs.helsinki.fi,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759844Ab0LNTx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 14:53:26 -0500
In-Reply-To: <4D078BDE.8060102@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tejun Heo <tj@kernel.org>
Date: Tue, 14 Dec 2010 16:23:10 +0100

> There's no in-kernel user left for these two obsolete functions.  Mark
> them deprecated and schedule for removal during 2.6.39 cycle.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: David S. Miller <davem@davemloft.net>
