From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next] net: Provide details on watchdog timeout.
Date: Mon, 09 Aug 2010 13:12:24 -0700
Message-ID: <4C606128.5050607@candelatech.com>
References: <1281383954-23765-1-git-send-email-greearb@candelatech.com> <20100809.131017.112606336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40213 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab0HIUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:12:26 -0400
In-Reply-To: <20100809.131017.112606336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2010 01:10 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Mon,  9 Aug 2010 12:59:14 -0700
>
>> This keeps the WARN_ON but will also log normal kernel messages
>> after the WARN_ON logic has happened once.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> I think this warning is fine as-is.

Ok, thanks for looking.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

