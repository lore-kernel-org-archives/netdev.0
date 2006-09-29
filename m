From: Rick Jones <rick.jones2@hp.com>
Subject: Re: mii-tool gigabit support.
Date: Fri, 29 Sep 2006 10:54:54 -0700
Message-ID: <451D5DEE.2080609@hp.com>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>	<Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>	<451AD1D6.4030708@intel.com>	<1159546378.2761.5.camel@dhollis-lnx.sunera.com> <20060929101215.649a9e32@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Hollis <dhollis@davehollis.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	dean gaudet <dean@arctic.org>, Jeff Garzik <jgarzik@pobox.com>,
	dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:32739 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751186AbWI2RzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 13:55:00 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060929101215.649a9e32@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2) develop some style
>>of register description definition type of text file, maybe XML, maybe
>>INI style or something stored in /etc/ethtool as <drivername>.conf or
>>something like that.  This way, ethtool doesn't have to be
>>changed/updated/patched/likely-bug-added for every single device known
>>to man.  
>>
>>Just a thought.
> 
>  
> We could switch to shared libraries like 'tc' uses.

 From a practical standpoint is shipping a new config file or a new shared 
library all that much different from a new ethtool binary?

rick
