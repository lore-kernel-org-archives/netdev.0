From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] Documentation: fix ascii art in networking docs
Date: Sat, 16 Sep 2017 12:47:53 -0700
Message-ID: <9263e528-7b00-9099-ecde-ed35339c218f@infradead.org>
References: <20170916162217.GA11237@amd> <87efr65wyg.fsf@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Netdev list <netdev@vger.kernel.org>
To: Andreas Schwab <schwab@linux-m68k.org>, Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38977 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdIPTr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 15:47:56 -0400
In-Reply-To: <87efr65wyg.fsf@linux-m68k.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/17 11:18, Andreas Schwab wrote:
> On Sep 16 2017, Pavel Machek <pavel@ucw.cz> wrote:
> 
>> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
>> index 5e40e1f..6309e90 100644
>> --- a/Documentation/networking/switchdev.txt
>> +++ b/Documentation/networking/switchdev.txt
>> @@ -29,7 +29,7 @@ with SR-IOV or soft switches, such as OVS, are possible.
>>                        sw1p1  +  sw1p3  +  sw1p5  +          eth1
>>                          +    |    +    |    +    |            +
>>                          |    |    |    |    |    |            |
>> -                     +--+----+----+----+-+--+----+---+  +-----+-----+
>> +                     +--+----+----+----+----+----+---+  +-----+-----+
>>                       |         Switch driver         |  |    mgmt   |
>>                       |        (this document)        |  |   driver  |
>>                       |                               |  |           |
>>
> 
> This is all mis-aligned.  How about replacing all the thin space
> characters by normal spaces?

Yes, there are lots of non-ASCII "spaces" in the ASCII art.  :(

-- 
~Randy
