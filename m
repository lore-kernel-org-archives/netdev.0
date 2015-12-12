From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] uapi: export ila.h
Date: Fri, 11 Dec 2015 23:41:57 -0500 (EST)
Message-ID: <20151211.234157.1518389637155421184.davem@davemloft.net>
References: <20151210091420.3e785232@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbbLLEl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 23:41:59 -0500
In-Reply-To: <20151210091420.3e785232@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 10 Dec 2015 09:14:20 -0800

> The file ila.h used for lightweight tunnels is being used by iproute2
> but is not exported yet.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable, thanks.
