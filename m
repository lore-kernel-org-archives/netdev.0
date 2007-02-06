From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 05/11] bonding: Replace kmalloc() + memset() pairs with
 the appropriate kzalloc() calls
Date: Mon, 05 Feb 2007 21:45:09 -0500
Message-ID: <45C7EBB5.3060001@pobox.com>
References: <200702060032.l160W7hH004630@shell0.pdx.osdl.net> <20070205.180540.35014717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	lkmaillist@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48049 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964778AbXBFCpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 21:45:15 -0500
In-Reply-To: <20070205.180540.35014717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Mon, 05 Feb 2007 16:31:04 -0800
> 
>> From: "Joe Jin" <lkmaillist@gmail.com>
>>
>> Replace kmalloc() + memset() pairs with the appropriate kzalloc() calls in
>> the bonding driver.
>>
>> Signed-off-by: Joe Jin <lkmaillist@gmail.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Jeff, you got this one?

nope, didn't see it


