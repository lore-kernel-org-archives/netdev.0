From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: use bitmap_weight
Date: Sat, 17 Nov 2012 22:01:48 -0500 (EST)
Message-ID: <20121117.220148.933381645515454891.davem@davemloft.net>
References: <1353134389-25583-1-git-send-email-akinobu.mita@gmail.com>
	<50A83DAF.8000408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, linux-sctp@vger.kernel.org, sri@us.ibm.com,
	netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab2KRDBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 22:01:50 -0500
In-Reply-To: <50A83DAF.8000408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Sat, 17 Nov 2012 20:45:19 -0500

> On 11/17/2012 01:39 AM, Akinobu Mita wrote:
>> Use bitmap_weight to count the total number of bits set in bitmap.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Cc: Sridhar Samudrala <sri@us.ibm.com>
>> Cc: linux-sctp@vger.kernel.org
>> Cc: netdev@vger.kernel.org
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks.
