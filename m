From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Tue, 03 Aug 2010 16:28:06 -0700 (PDT)
Message-ID: <20100803.162806.226750720.davem@davemloft.net>
References: <4C584DB2.8020406@hartkopp.net>
	<1280856828.3266.839.camel@pohly-mobl1.ikn.intel.com>
	<4C5856E3.3070606@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@intel.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	matthias.fuchs@esd.eu
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51201
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756696Ab0HCX1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:27:48 -0400
In-Reply-To: <4C5856E3.3070606@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 03 Aug 2010 19:50:27 +0200

> On 03.08.2010 19:33, Patrick Ohly wrote:
>> On Tue, 2010-08-03 at 10:11 -0700, Oliver Hartkopp wrote:
>>>> I'm fine with using a simple u8. I'm not sure where I picked up the
>>>> union thing, it's not something that I usually do in my own code.
>>>>
>>>
>>> :-)
>>>
>>> Im currently busy until next week, would you like to provide a patch?
>> 
>> Sorry, I have to pass. I'm busy elsewhere myself. MeeGo and
>> SyncEvolution plus real life consume all of my time nowadays.
> 
> Working for MeeGo is a good excuse ;-)
> 
> Will pick that task next week.

Thanks guys.
