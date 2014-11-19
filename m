From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Wed, 19 Nov 2014 13:26:06 -0500 (EST)
Message-ID: <20141119.132606.1227813907717315973.davem@davemloft.net>
References: <20141117130201.GB1872@nanopsycho.orion>
	<03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
	<20141119124043.GC1926@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkadmany@codeaurora.org, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbaKSS0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:26:09 -0500
In-Reply-To: <20141119124043.GC1926@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 19 Nov 2014 13:40:43 +0100

> No, that is certainly not the reason. If libnl3 does not suit you, use a
> different lib. It is in my opinion unacceptaptable to work around
> certain licence issues by adding parallel sysfs api (not to mention that
> sysfs is totally unsuitable for that).
> 
> You should use existing Netlink API. That's it.

+1, these arguments for adding sysfs attributes are unacceptable.
