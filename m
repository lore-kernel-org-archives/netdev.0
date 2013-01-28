From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] via-rhine: add 64bit statistics.
Date: Mon, 28 Jan 2013 18:43:28 -0500 (EST)
Message-ID: <20130128.184328.1504809258950862340.davem@davemloft.net>
References: <5100b2f8.1883650a.37e6.17b4@mx.google.com>
	<1359005741.12374.1589.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie.gloudon@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab3A1Xn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:43:29 -0500
In-Reply-To: <1359005741.12374.1589.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jan 2013 21:35:41 -0800

> On Thu, 2013-01-24 at 00:05 -0400, Jamie Gloudon wrote:
>> Switch to use ndo_get_stats64 to get 64bit statistics.
>> 
>> Signed-off-by: Jamie Gloudon <jamie.gloudon@gmail.com>
>> Tested-by: Jamie Gloudon <jamie.gloudon@gmail.com> 
>> ---
>>  drivers/net/ethernet/via/via-rhine.c | 47 ++++++++++++++++++++++++++++++------
>>  1 file changed, 39 insertions(+), 8 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
