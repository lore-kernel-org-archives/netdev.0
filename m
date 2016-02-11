From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169: Bad implementation of netif_carrier_*
Date: Thu, 11 Feb 2016 06:12:50 -0500 (EST)
Message-ID: <20160211.061250.1340671752357908695.davem@davemloft.net>
References: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
	<20160211.033915.51059595679987845.davem@davemloft.net>
	<1455187969.3447.4.camel@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcBKLMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 06:12:52 -0500
In-Reply-To: <1455187969.3447.4.camel@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Thu, 11 Feb 2016 12:52:49 +0200

> On Thu, 2016-02-11 at 03:39 -0500, David Miller wrote:
>> From: Corcodel Marian <asd@marian1000.go.ro>
>> Date: Thu, 11 Feb 2016 08:27:43 +0200
>> 
>> >   On probe stage what carrier to stop and rest two situation
>> >   netif_carrier_* is slow and disturbing autonegociation process.
>> > 
>> > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
>> 
>> This doesn't tell us at all why your change is valid.  You aren't
>> going into the details of what you mean by "disturbing" and why it
>> being "slow" is really a problem.
>> 
>> In general, your patches are of a very low quality.  You give never
>> give us enough information to properly evaluate your patch.
>> 
>> It is unlikely that even one of your patches will be applied by
>> me until you fix this fundamental problem with your submissions.
> 
> May bee netif_carrier_* is good on slow changes of link good status of
> interrupt ,is unable to keep track changes from link good interrupt.

You're still not telling us anything.

The situation with your submissions is not improving.

Sorry.
