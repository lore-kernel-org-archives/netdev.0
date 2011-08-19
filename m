From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC v3 0/75] enable SKB paged fragment lifetime
 visibility
Date: Fri, 19 Aug 2011 06:34:10 -0700 (PDT)
Message-ID: <20110819.063410.475175569086272526.davem@davemloft.net>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	<20110819.062958.1560313540665582388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358Ab1HSNeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 09:34:12 -0400
In-Reply-To: <20110819.062958.1560313540665582388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 19 Aug 2011 06:29:58 -0700 (PDT)

> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Fri, 19 Aug 2011 14:26:33 +0100
> 
>> This is v3 of my series to enable visibility into SKB paged fragment's
> 
> Please tone down the patch count :-/  I'm not going to review anything more
> than ~20 or so patches at a time from any one person.

Also none of your patches will even apply to net-next GIT since nearly
all the ethernet drivers have been moved under drivers/net/ethernet
