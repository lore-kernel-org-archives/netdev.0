From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 14:52:27 +0200
Message-ID: <467D178B.8080503@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52838 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbXFWMwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 08:52:38 -0400
In-Reply-To: <467D0C97.1000000@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
> 
>>>
>>>Sorry, it's simply a matter of time.  We have been extremely busy with
>>>other projects and two presentations (mgmt, customers, and press) the
>>>last two weeks and have worked on the other changes this week.  I'm
>>>sorry I haven't yet been able to look at your rtnl_link code close
>>>enough, but it's definitely on my todo list.  Starting on Sunday I'll
>>>be on a business trip to .jp for a week, and I hope I get to it in
>>>that week, otherwise on return.
>>>    
>>
>>
>>Sorry, but busy is no reason for merging code that has deprecated
>>(at least by me :)) behaviour. Please change this before submitting
>>for inclusion.
>>  
> 
> i was just looking through the mailings regarding your suggested changes
> (e.g. in VLAN, DUMMY and IFB) an none of them currently went into the
> kernel and the discussion on some topics (especially in the VLAN case)
> is just running.


They are all in the net-2.6.23 tree.
