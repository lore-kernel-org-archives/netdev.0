From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] net: dsa: mv88e6131: Use common initialization
 functions
Date: Wed, 01 Apr 2015 22:00:52 -0400 (EDT)
Message-ID: <20150401.220052.1588727480151160711.davem@davemloft.net>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
	<1427937719-11630-2-git-send-email-andrew@lunn.ch>
	<551C9DD7.7040505@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbbDBCA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 22:00:56 -0400
In-Reply-To: <551C9DD7.7040505@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 01 Apr 2015 18:39:35 -0700

> On 04/01/2015 06:21 PM, Andrew Lunn wrote:
>> From: Guenter Roeck <linux@roeck-us.net>
>>
>> Common initialization functions will be needed to enable
>> HW bridging support.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
> Hi Andrew,
> 
> No idea how David handles this, but I would have expected to see your
> Signed-off-by: here to reflect the submit path.

Agreed, Andrew should be signing off on this.
