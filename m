From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
Date: Tue, 25 Apr 2017 10:43:00 +0200
Message-ID: <bea0f00d-37d7-5a4a-1e5d-f5758da7e158@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
 <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dev@kicherer.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:12519 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760528AbdDYInU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:43:20 -0400
In-Reply-To: <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/25/2017 08:48 AM, Marc Kleine-Budde wrote:
> On 04/25/2017 08:19 AM, Oliver Hartkopp wrote:
>> Hello Dave,
>>
>> unfortunately the initial network namespace support by Mario Kicherer
>> (8e8cda6d737d) slipped into net-next without further review and Marc pushed
>> the code without my Acked-by. Due to the fact that this code was in net-next
>> now I spent some nights to fix, clean up, finalize and test the missing pieces
>> for the namespace support for the CAN subsystem in net/can.
>>
>> As Marc is currently *VERY* unresponsive on the mailing list due to his 'real'
>
> ... and holidays :) But I'm back in the office now.

I created a cleaned patch series to provide more detailed and proper 
patches. And these patches are based on Dave's net-next as you did not 
push your latest changes in mkl/linux-can-next to the public on week ago.

When you manage to get this series integrated today then it would be ok 
for me. Otherwise we should Dave take this series directly.

Thanks,
Oliver
