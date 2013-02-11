From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: fix sparse warning
Date: Mon, 11 Feb 2013 14:18:18 -0500 (EST)
Message-ID: <20130211.141818.916460642650848685.davem@davemloft.net>
References: <20130211082228.1f1d7f88@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759270Ab3BKTSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:18:21 -0500
In-Reply-To: <20130211082228.1f1d7f88@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 11 Feb 2013 08:22:28 -0800

> Fixes sparse complaints about dropping __user in casts.
>  warning: cast removes address space of expression
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
