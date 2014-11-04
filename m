From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/5] stmmac: pci: remove FSF address
Date: Tue, 04 Nov 2014 15:15:04 -0500 (EST)
Message-ID: <20141104.151504.197433296248263241.davem@davemloft.net>
References: <54593285.3030201@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andriy.shevchenko@intel.com
To: xose.vazquez@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaKDUPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 15:15:07 -0500
In-Reply-To: <54593285.3030201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Tue, 04 Nov 2014 21:09:41 +0100

> David Miller wrote:
> 
>> Andy Shevchenko wrote:
>>> The FSF address is subject to change, thus remove it from the file.
>>> 
>>> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
>> 
>> I cound 90t instances of this under drivers/net, therefore if this change is
>           ^^^^^^^^^^^^^
>> appropriate I'd rather someone script this and kill it across entire
>> subdirectories.
> 
> It's a bit more, 555:

I meant "nine hundred something", the 't' it my finger slipping down
one row on my keyboard :-)
