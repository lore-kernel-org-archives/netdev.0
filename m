From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Tue, 22 Oct 2013 15:46:58 -0400 (EDT)
Message-ID: <20131022.154658.839997313195271677.davem@davemloft.net>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
	<1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
	<1382469746.19269.55.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, nbd@openwrt.org, blogic@openwrt.org,
	jogo@openwrt.org, gary@mlbassoc.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab3JVTrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:47:00 -0400
In-Reply-To: <1382469746.19269.55.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Tue, 22 Oct 2013 14:22:26 -0500

> On Tue, 2013-10-22 at 11:23 -0700, Florian Fainelli wrote:
>> This patch adds an Ethernet Switch generic netlink configuration API
>> which allows for doing the required configuration of managed Ethernet
>> switches commonly found in Wireless/Cable/DSL routers in the market.
> 
> "swconfig" probably means "switch config", but is there any way to
> rename this away from the "sw" prefix, since "sw" typically means
> "software" and not "switch"?

Agreed.
