From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tipc: Add socket options to get number of
 queued messages
Date: Sun, 05 Jul 2009 19:48:52 -0700 (PDT)
Message-ID: <20090705.194852.40898712.davem@davemloft.net>
References: <1246368339-19754-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oscar.medina@motorola.com
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754570AbZGFCsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:48:46 -0400
In-Reply-To: <1246368339-19754-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 30 Jun 2009 09:25:39 -0400

> From: oscar.medina@motorola.com <oscar.medina@motorola.com>
> 
> This patch allows a TIPC application to determine the number of messages
> currently waiting in a socket's receive queue (TIPC_SOCK_RECVQ_DEPTH) or
> in all TIPC socket receive queues (TIPC_NODE_RECVQ_DEPTH).
> 
> Signed-off-by: Oscar Medina <oscar.medina@motorola.com>
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied to net-next-2.6
