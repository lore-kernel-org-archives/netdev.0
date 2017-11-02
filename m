From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 0/3] net: dsa: lan9303: Fix STP and flooding
 issues
Date: Thu, 2 Nov 2017 10:06:49 +0100
Message-ID: <45082a4a-9233-2b00-009c-0a7e6568d61d@egil-hjelmeland.no>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
 <20171101.213038.799755298352005372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:38450 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750883AbdKBJHH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Nov 2017 05:07:07 -0400
In-Reply-To: <20171101.213038.799755298352005372.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01. nov. 2017 13:30, David Miller wrote:
> From: Egil Hjelmeland <privat@egil-hjelmeland.no>
> Date: Tue, 31 Oct 2017 15:47:59 +0100
> 
>> This patch set finishes the STP support, and fixes flooding issues.
>>
> 
> Series applied, thank you.
> 

Thanks! Based on happy testing on my desktop, I conclude that the 
net-next lan9303 driver has now reached a level where my employer 
Zenitel can use it out of the box. We have covered everything we need 
from our proprietary driver.

Our old proprietary driver can not separate the interfaces. Being able 
to do so may be interesting in some custom usages of our product. And we 
are very much looking forward to Andrew progressing his series for IGMP 
snooping for local traffic!

Egil
