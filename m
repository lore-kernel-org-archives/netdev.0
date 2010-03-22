From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: check min TTL on received ICMP packets
Date: Sun, 21 Mar 2010 18:12:10 -0700 (PDT)
Message-ID: <20100321.181210.42774477.davem@davemloft.net>
References: <20100319.210801.39166378.davem@davemloft.net>
	<27142077.3891269129914984.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753201Ab0CVBLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:11:48 -0400
In-Reply-To: <27142077.3891269129914984.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Sat, 20 Mar 2010 17:05:14 -0700 (PDT)

>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 18 Mar 2010 14:27:32 -0700
>> 
>> > Please apply to 2.6.33 since it basically a "follow correct RFC"
>> > fix to original GTSM patch.
>> 
> 
> I meant 2.6.34... min_ttl is not in 2.6.33

Gotcha.
