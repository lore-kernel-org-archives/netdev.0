From: David Miller <davem@davemloft.net>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH 2/2] [sky2] Fix for interrupt
 handler
Date: Tue, 13 Nov 2012 03:14:46 -0500 (EST)
Message-ID: <20121113.031446.1481052044099452015.davem@davemloft.net>
References: <1341394726.14972.41.camel@mlindner-lin.skd.de>
	<20121025223646.GA1131@elie.Belkin>
	<20121103100447.GA2003@elie.Belkin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdg@debian.org, mlindner@marvell.com, shemminger@vyatta.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: jrnieder@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab2KMIOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 03:14:53 -0500
In-Reply-To: <20121103100447.GA2003@elie.Belkin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Nieder <jrnieder@gmail.com>
Date: Sat, 3 Nov 2012 03:04:48 -0700

> On October 25, Jonathan Nieder wrote:
>> Mirko Lindner wrote:
> 
>>> Re-enable interrupts if it is not our interrupt
>>>
>>> Signed-off-by: Mirko Lindner <mlindner@marvell.com>
> [...]
>> Tested-by: Julian Gilbey <jdg@debian.org> # 3.2.y, Inspiron 1545
> 
> Ping.  Dave, is
> 
>   d663d181b9e9 sky2: Fix for interrupt handler
> 
> a candidate for inclusion in 3.0-, 3.2-, and 3.4-stable?  (It was
> applied upstream during the 3.6 merge window.)  I don't see it in
> the list at [2].

This looks fine.
