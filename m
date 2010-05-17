From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] sky2: update
Date: Mon, 17 May 2010 09:55:01 -0700 (PDT)
Message-ID: <20100517.095501.71136126.davem@davemloft.net>
References: <20100513161247.833356588@vyatta.com>
	<20100514.031501.57481177.davem@davemloft.net>
	<20100514081957.00f342d5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754885Ab0EQQyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 12:54:52 -0400
In-Reply-To: <20100514081957.00f342d5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 14 May 2010 08:19:57 -0700

> On Fri, 14 May 2010 03:15:01 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 13 May 2010 09:12:47 -0700
>> 
>> > Bunch of patches from Mike, with some additional comments.
>> 
>> All applied to net-next-2.6, thanks.
> 
> The first one needs to go to net-2.6 because it a regression:
> Current code will lose multicast addresses when the automatic
> recovery from stuck chip happens. Auto recovery happens a lot
> under load on some configurations.

2.6.34 got released yesterday, so it is a moot point.

Just submit it to -stable.
