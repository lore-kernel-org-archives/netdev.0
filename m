From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: ethtool: Added port speed macros.
Date: Tue, 19 May 2015 14:52:02 -0400 (EDT)
Message-ID: <20150519.145202.617793736993996813.davem@davemloft.net>
References: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
	<20150518.114630.1938175226193925552.davem@davemloft.net>
	<1432054835.12412.28.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: parav.pandit@avagotech.com, netdev@vger.kernel.org, bwh@kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbbESSwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 14:52:04 -0400
In-Reply-To: <1432054835.12412.28.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 19 May 2015 18:00:35 +0100

> On Mon, 2015-05-18 at 11:46 -0400, David Miller wrote:
>> From: Parav Pandit <parav.pandit@avagotech.com>
>> Date: Mon, 18 May 2015 16:31:47 +0530
>> 
>> > Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>
>> 
>> I thought we had decided that we weren't going to keep adding
>> convenience macros for new speeds, and were simply going to use
>> the appropriate constants in the future.
>> 
>> Ben?
> 
> That's what I thought, but you accepted commit dcf972a334dd "ethtool,
> net/mlx4_en: Add 100M, 20G, 56G speeds ethtool reporting support" not so
> long ago.

Grumble... my bad.

Given that I should probably accept this patch set as well, hopefully
we won't get very many more of these any time soon.

Sorry for creating this mess.
