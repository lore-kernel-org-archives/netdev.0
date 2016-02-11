From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169: Bad implementation of netif_carrier_*
Date: Thu, 11 Feb 2016 03:39:15 -0500 (EST)
Message-ID: <20160211.033915.51059595679987845.davem@davemloft.net>
References: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcBKIjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 03:39:23 -0500
In-Reply-To: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Thu, 11 Feb 2016 08:27:43 +0200

>   On probe stage what carrier to stop and rest two situation
>   netif_carrier_* is slow and disturbing autonegociation process.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>

This doesn't tell us at all why your change is valid.  You aren't
going into the details of what you mean by "disturbing" and why it
being "slow" is really a problem.

In general, your patches are of a very low quality.  You give never
give us enough information to properly evaluate your patch.

It is unlikely that even one of your patches will be applied by
me until you fix this fundamental problem with your submissions.
