From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: cleanup tap related functions
Date: Wed, 01 Jan 2014 23:44:29 -0500 (EST)
Message-ID: <20140101.234429.188732039609827572.davem@davemloft.net>
References: <20131230104922.7b16965e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaABEoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:44:30 -0500
In-Reply-To: <20131230104922.7b16965e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Dec 2013 10:49:22 -0800

> Cleanups in netlink_tap code
>  * remove unused function netlink_clear_multicast_users
>  * make local function static
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
