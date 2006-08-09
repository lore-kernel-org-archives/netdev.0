From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 09 Aug 2006 13:45:48 +0300
Message-ID: <44D9BCDC.2070107@tcs.hut.fi>
References: <20060808221651.GS14627@postel.suug.ch> <20060808.164345.91207648.davem@davemloft.net> <44D98133.8040707@tcs.hut.fi> <20060808.233442.41636358.davem@davemloft.net> <44D99E73.1060305@tcs.hut.fi> <20060809092311.GU14627@postel.suug.ch> <44D9ADFB.90200@tcs.hut.fi> <20060809094818.GW14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:20488 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1030673AbWHIKpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 06:45:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060809094818.GW14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 12:42
>> Ok, it might require quite big changes to the existing code, but if
>> someone is willing to take a look at it I wouldn't be against it :-)
> 
> I'll provide a patch soon.

Great, but just out of curiosity: about when is soon? My source address
routing changes are likely to cause some conflicts with your code, so
I'm just trying to plan ahead so I don't need to spend half an eternity
merging the afore mentioned conflicts.

Regards,
Ville
