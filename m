From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: use rht_obj() consistently
Date: Sat, 14 Feb 2015 20:31:52 -0800 (PST)
Message-ID: <20150214.203152.352400661413090421.davem@davemloft.net>
References: <1423860161-20875-1-git-send-email-johannes@sipsolutions.net>
	<20150213205853.GA18659@casper.infradead.org>
	<20150213214208.GB18659@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	johannes.berg@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbbBOEYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 23:24:44 -0500
In-Reply-To: <20150213214208.GB18659@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 13 Feb 2015 21:42:08 +0000

> On 02/13/15 at 08:58pm, Thomas Graf wrote:
>> On 02/13/15 at 09:42pm, Johannes Berg wrote:
>> > From: Johannes Berg <johannes.berg@intel.com>
>> > 
>> > Looking at the RHT code I found two places where this was
>> > done manually rather than using the rht_obj() helper, use
>> > that instead.
>> > 
>> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>> 
>> Acked-by: Thomas Graf <tgraf@suug.ch>
> 
> Actually, this is already "fixed" in net-next.

So I'm going to toss this.
