From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/7] X25: Add if_x25.h and x25 to device identifiers
Date: Thu, 22 Apr 2010 16:13:42 -0700 (PDT)
Message-ID: <20100422.161342.60085636.davem@davemloft.net>
References: <1271719717.2802.77.camel@ibex>
	<20100420.163558.83598373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751550Ab0DVXNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:13:37 -0400
In-Reply-To: <20100420.163558.83598373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 20 Apr 2010 16:35:58 -0700 (PDT)

> From: Andrew Hendry <andrew.hendry@gmail.com>
> Date: Tue, 20 Apr 2010 09:28:37 +1000
> 
>> diff --git a/include/linux/if_x25.h b/include/linux/if_x25.h
>> new file mode 100644
>> index 0000000..897765f
>> --- /dev/null
>> +++ b/include/linux/if_x25.h
>> @@ -0,0 +1,26 @@
>> +/*
>> + *  Linux X.25 packet to device interface
> 
> Headers meant to be used by userspace must be added
> to the include/linux/Kbuild file.

I got tired of waiting days for you to get to this so I
took care of it myself.

All 7 patches applied to net-next-2.6
