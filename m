From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: print information on all routing tables
Date: Sun, 23 Mar 2008 22:45:40 -0700 (PDT)
Message-ID: <20080323.224540.20122302.davem@davemloft.net>
References: <20080317140236.6160fb4f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbYCXFpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:45:40 -0400
In-Reply-To: <20080317140236.6160fb4f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Mar 2008 14:02:36 -0700

> Make /proc/net/fib_trie and /proc/net/fib_triestat display
> all routing tables, not just local and main.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6.26
