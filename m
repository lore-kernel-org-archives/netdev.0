From: Massimo Cetra <mcetra@navynet.it>
Subject: Re: [Bug #14378] Problems with net/core/skbuff.c
Date: Tue, 13 Oct 2009 11:23:48 +0200
Message-ID: <4AD44724.4040105@navynet.it>
References: <zJ_pXHNwoHC.A.akB.Aal0KB@chimera>	<r-4Wjt4coy.A.CwC.Wal0KB@chimera> <20091012.034224.64980795.davem@davemloft.net> <4AD44435.3050703@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Massimo Cetra <ctrixk@navynet.it>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759276AbZJMJYf@vger.kernel.org>
In-Reply-To: <4AD44435.3050703@navynet.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Massimo Cetra ha scritto:
> David Miller ha scritto:
>> From: "Rafael J. Wysocki" <rjw@sisk.pl>
>> Date: Mon, 12 Oct 2009 00:22:04 +0200 (CEST)
>>
>>  
>>> Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=14378
>>> Subject        : Problems with net/core/skbuff.c
>>> Submitter    : Massimo Cetra <mcetra@navynet.it>
>>> Date        : 2009-10-08 14:51 (4 days old)
>>> References    : http://marc.info/?l=linux-kernel&m=125501488220358&w=4
>>>     
>>
>> I don't know what to do about this one.
>>
>> The user indicates that they have the vserver patches applied,
>> so maybe there is some interaction with that stuff.
>>   
> Actually i found another oops which is very similar to the previous one.

And here it is another one, this time triggered by postfix, where mor 
drbd nor vserver are involved.
This is not the same server where the other oopses were grabbed.

Max
