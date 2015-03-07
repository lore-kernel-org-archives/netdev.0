From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Sat, 07 Mar 2015 01:14:43 -0500 (EST)
Message-ID: <20150307.011443.2241226578473467570.davem@davemloft.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
	<20150306.002410.1359006818497057668.davem@davemloft.net>
	<20150307031013.GC502@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbCGGOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 01:14:45 -0500
In-Reply-To: <20150307031013.GC502@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Fri, 6 Mar 2015 22:10:13 -0500

> You have made it clear that despite the value others see in it, you are
> opposed to setting the speed and duplex on things like tuntap and I
> agree with you on this.  Doing that does nothing but continue to enable
> offload hardware to live in userspace and that is not the proper
> direction the kernel should take.

This is a scarecrow.

HW offloading has nothing at all to do with reporting complete
bullshit link speed and duplex values on team/bonding devices.
