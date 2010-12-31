From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
Date: Fri, 31 Dec 2010 10:42:43 -0800 (PST)
Message-ID: <20101231.104243.104051102.davem@davemloft.net>
References: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
	<20101220205018.24232.994.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907Ab0LaSmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:42:12 -0500
In-Reply-To: <20101220205018.24232.994.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 20 Dec 2010 12:50:18 -0800

> This patch adds application tlv handlers. Networking stacks
> may use the application priority to set the skb priority of
> their stack using the negoatiated dcbx priority.
> 
> This patch provides the dcb_{get|set}app() routines for the
> stack to query these parameters. Notice lower layer drivers
> can use the dcbnl_ops routines if additional handling is
> needed. Perhaps in the firmware case for example
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
