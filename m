From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESUBMIT3 net-next 1/2] IPv6 routing, NLM_F_* flag
 support: warn if new route is created without NLM_F_CREATE
Date: Mon, 14 Nov 2011 14:36:01 -0500 (EST)
Message-ID: <20111114.143601.114729317764526592.davem@davemloft.net>
References: <1321265689.1858.27.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1KNTgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:36:07 -0500
In-Reply-To: <1321265689.1858.27.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Mon, 14 Nov 2011 12:14:49 +0200

> The support for NLM_F_* flags at IPv6 routing requests.
> 
> Warn if NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
> creating new table. Later NLM_F_CREATE may be required for
> new route creation.
> 
> Patch created against linux-3.2-rc1
> 
> Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

Applied.
