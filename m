From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] thermal: shorten too long mcast group name
Date: Thu, 21 Mar 2013 10:53:24 -0400 (EDT)
Message-ID: <20130321.105324.1538473102849136394.davem@davemloft.net>
References: <1363693648-10015-3-git-send-email-yamato@redhat.com>
	<20130320.120832.24140728832512231.davem@davemloft.net>
	<20130321.164623.197949072785579777.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab3CUOx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 10:53:26 -0400
In-Reply-To: <20130321.164623.197949072785579777.yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Thu, 21 Mar 2013 16:46:23 +0900 (JST)

>> From: Masatake YAMATO <yamato@redhat.com>
>> Date: Tue, 19 Mar 2013 20:47:28 +0900
>> 
>>> The original name is too long.
>>> 
>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>> 
>> This change needs to go in via the Thermal driver maintainers.
> 
> Thanks. I've submitted the patch to linux-acpi ML.

I already applied the patch to my tree, didn't you read
the rest of this thread?

And in the future, order your patches such that you fix the bug before
adding the assertion.
