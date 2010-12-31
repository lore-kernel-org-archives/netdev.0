From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] net_dcb: add application notifiers
Date: Fri, 31 Dec 2010 10:42:37 -0800 (PST)
Message-ID: <20101231.104237.71109059.davem@davemloft.net>
References: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
	<20101220205023.24232.72153.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753546Ab0LaSmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:42:06 -0500
In-Reply-To: <20101220205023.24232.72153.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 20 Dec 2010 12:50:24 -0800

> DCBx applications priorities can be changed dynamically. If
> application stacks are expected to keep the skb priority
> consistent with the dcbx priority the stack will need to
> be notified when these changes occur.
> 
> This patch adds application notifiers for the stack to register
> with.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
