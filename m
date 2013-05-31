From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] snmp6: remove IPSTATS_MIB_CSUMERRORS
Date: Fri, 31 May 2013 16:27:07 -0700 (PDT)
Message-ID: <20130531.162707.49262040783532550.davem@davemloft.net>
References: <1370013236.5109.100.camel@edumazet-glaptop>
	<1370014677-4626-1-git-send-email-nicolas.dichtel@6wind.com>
	<1370020296.5109.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab3EaX1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:27:09 -0400
In-Reply-To: <1370020296.5109.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 May 2013 10:11:36 -0700

> On Fri, 2013-05-31 at 17:37 +0200, Nicolas Dichtel wrote:
>> This stat is not relevant in IPv6, there is no checksum in IPv6 header.
>> Just leave a comment to explain the hole.
>> 
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
