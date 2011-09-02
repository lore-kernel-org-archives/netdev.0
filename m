From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC, 1/2] ethtool: Implement private flags interface for
 ethtool application.
Date: Fri, 2 Sep 2011 14:11:20 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F0173FF8607@orsmsx508.amr.corp.intel.com>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
 <20110902.165524.1076389492712310664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5117 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822Ab1IBVLV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:11:21 -0400
In-Reply-To: <20110902.165524.1076389492712310664.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, September 02, 2011 1:55 PM
>To: Wyborny, Carolyn
>Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
>Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
>ethtool application.
>
>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>Date: Fri,  2 Sep 2011 13:50:30 -0700
>
>> This patch completes the user space implementation of the private
>> flags inteface in ethtool. Using -b/-B options.
>>
>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
>
>The only use case you show here is something generic which other
>chips have, Energy Efficient Ethernet.
>
>Making an attribute private which is present widely amonst various
>networking chips makes no sense at all.
>
>It deserved a generic ethtool flag.

Fair enough on this particular feature, but does that negate the implementation suggestion altogether?  I can send an updated feature implementation for the use case using DMA Coalescing if that will help.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
