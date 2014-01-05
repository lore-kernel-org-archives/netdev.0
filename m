From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tipc: remove unused code
Date: Sat, 04 Jan 2014 20:20:43 -0500 (EST)
Message-ID: <20140104.202043.2208174959056799596.davem@davemloft.net>
References: <20140104134748.0ddff391@nehalam.linuxnetplumber.net>
	<20140104134914.13dd63e9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaAEBUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:20:44 -0500
In-Reply-To: <20140104134914.13dd63e9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 4 Jan 2014 13:49:14 -0800

> Remove dead code;
>        tipc_bearer_find_interface
>        tipc_node_redundant_links
> 
> This may break out of tree version of TIPC if there still is one.
> But that maybe a good thing :-)
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
