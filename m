From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] VXLAN: Fix sparse warnings.
Date: Wed, 27 Mar 2013 00:53:00 -0400 (EDT)
Message-ID: <20130327.005300.2089836683155202403.davem@davemloft.net>
References: <1364322570-27179-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829Ab3C0ExB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 00:53:01 -0400
In-Reply-To: <1364322570-27179-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 26 Mar 2013 11:29:30 -0700

> Fixes following warning:-
> drivers/net/vxlan.c:471:35: warning: symbol 'dev' shadows an earlier one
> drivers/net/vxlan.c:433:26: originally declared here
> drivers/net/vxlan.c:794:34: warning: symbol 'vxlan' shadows an earlier one
> drivers/net/vxlan.c:757:26: originally declared here
> 
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
