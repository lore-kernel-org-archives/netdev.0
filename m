From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4 2/5] fib_trie: remove unneeded NULL check
Date: Wed, 23 Jan 2008 20:38:31 -0800 (PST)
Message-ID: <20080123.203831.75964940.davem@davemloft.net>
References: <20080123224844.610730277@linux-foundation.org>
	<20080123224858.844259513@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753338AbYAXEiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 23:38:21 -0500
In-Reply-To: <20080123224858.844259513@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 23 Jan 2008 14:48:46 -0800

> Since fib_route_seq_show now uses hlist_for_each_entry(), the
> leaf info can not be NULL.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
