From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Tue, 22 Oct 2013 17:22:04 -0400 (EDT)
Message-ID: <20131022.172204.485588329844430729.davem@davemloft.net>
References: <CAGVrzcYCK3QBMgHnZ2T=wzeckX-enwJOu7DEcKHg3s=ABivLDQ@mail.gmail.com>
	<20131022.154722.1236352694540893148.davem@davemloft.net>
	<1382477150.19269.69.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, nbd@openwrt.org, blogic@openwrt.org,
	jogo@openwrt.org, gary@mlbassoc.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748Ab3JVVWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 17:22:08 -0400
In-Reply-To: <1382477150.19269.69.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Tue, 22 Oct 2013 16:25:50 -0500

> On Tue, 2013-10-22 at 15:47 -0400, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue, 22 Oct 2013 12:32:29 -0700
>> 
>> > 2013/10/22 Dan Williams <dcbw@redhat.com>:
>> >> On Tue, 2013-10-22 at 11:23 -0700, Florian Fainelli wrote:
>> >>> This patch adds an Ethernet Switch generic netlink configuration API
>> >>> which allows for doing the required configuration of managed Ethernet
>> >>> switches commonly found in Wireless/Cable/DSL routers in the market.
>> >>
>> >> "swconfig" probably means "switch config", but is there any way to
>> >> rename this away from the "sw" prefix, since "sw" typically means
>> >> "software" and not "switch"?
>> > 
>> > Sure, how about something like "enetsw"? I would like to avoid using
>> > "switch" too much since this is a C reserved keyword.
>> 
>> "swtch"? :-)
> 
> haha...  seriously though, "enetsw" or even "esw" or "ensw" would be
> better than plain "sw".  Your choice, I have no horse in the race other
> than the "not sw" horse :)

"enetsw" is fine by me :-)
