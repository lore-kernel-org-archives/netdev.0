From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Tue, 16 Apr 2013 14:00:32 -0400 (EDT)
Message-ID: <20130416.140032.376392714783850324.davem@davemloft.net>
References: <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
	<20130416.083503.643566585360141810.davem@davemloft.net>
	<loom.20130416T160452-895@post.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936043Ab3DPSAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 14:00:36 -0400
In-Reply-To: <loom.20130416T160452-895@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Baxter <jim_baxter@mentor.com>
Date: Tue, 16 Apr 2013 14:09:25 +0000 (UTC)

> David Miller <davem <at> davemloft.net> writes:
> 
>> 
>> 
>> When you post multiple versions of a patch, always say what is different
>> between the versions.
>> 
> 
> 
> Sorry, I was trying to differentiate between my first two messed up posts and 
> the correct patch post. I first forgot to mark it net-net and then I managed 
> to send it from y@relay1.mentorg.com.
> 
> Is there a better way to correct incorrect patch headers?

You post it again, but you say what you changed so that we know what
is happening.

You put such change annotations after the "---" seperator so that they
do not appear in the final commit message.
