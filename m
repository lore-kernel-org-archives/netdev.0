From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Fri, 06 Jul 2012 05:02:46 -0700 (PDT)
Message-ID: <20120706.050246.2187095151022601094.davem@davemloft.net>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
	<1341575919.3265.499.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christian.riesch@omicron.at, netdev@vger.kernel.org,
	oneukum@suse.de, edumazet@google.com, allan@asix.com.tw,
	kernel@teksavvy.com, grundler@chromium.org, tom.leiming@gmail.com,
	michael@riesch.at
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030264Ab2GFMCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 08:02:49 -0400
In-Reply-To: <1341575919.3265.499.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 13:58:39 +0200

> On Fri, 2012-07-06 at 13:33 +0200, Christian Riesch wrote:
>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>> ---
> 
>> -		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
>> +		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
>> +			   ret);
> 
> 
> Thats ridiculous
> 
> Not all checkpatch warnings are meaningful.
> 
> I mean, they probably are for new code, but for existing one this is a
> waste of time.

Agreed.
