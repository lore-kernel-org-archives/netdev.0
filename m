From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: neighbour: Add mcast_resolicit to
 configure the number of multicast resolicitations in PROBE state.
Date: Thu, 19 Mar 2015 14:30:23 -0400 (EDT)
Message-ID: <20150319.143023.106133968499336413.davem@davemloft.net>
References: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
	<550AE13C.5080906@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
	Yanjun.Zhu@windriver.com
To: ulf.samuelsson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231AbbCSSa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:30:26 -0400
In-Reply-To: <550AE13C.5080906@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Date: Thu, 19 Mar 2015 15:46:20 +0100

> I think it would be good, if the initial value of "mcast_resolicit"
> could be specified using Kconfig.

Please no :-/
