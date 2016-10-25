From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: Redundancy support through HSR and PRP
Date: Tue, 25 Oct 2016 15:03:33 +0200
Message-ID: <580F5825.9080109@alten.se>
References: <57FBDF33.1060606@ti.com> <5808F9FC.1080802@ti.com>
 <580E3854.4030009@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        "David Miller" <davem@davemloft.net>,
        "Heise, Peter" <peter.heise@airbus.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.webland.nu ([37.26.152.132]:40985 "HELO mx03.webland.nu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
        id S965886AbcJYNT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 09:19:27 -0400
In-Reply-To: <580E3854.4030009@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-10-24 18:35, Murali Karicheri wrote:
>> On 10/10/2016 02:34 PM, Murali Karicheri wrote:
>>> All,
>>>
>>> Wondering if there plan to add PRP driver support, like HSR in Linux? AFAIK, PRP
>>> adds trailor to Ethernet frame and is used for Redundancy management like HSR.
>>> So wondering why this is not supported.
>>>
>>> Thanks
>>>
>> I need to work on a prp driver for Linux. So if there is already someone working
>> on this, I would like to join and contribute. Either way please respond so that
>> I can work to add this support. 
>>
> + Arvid
> 
> Didn't copy HSR owner in my original email. Copying now.
> 

Hi Murali,

I'm not aware of anyone working on PRP support.

I will have very little time, if any, to help out with this (or even test changes).
In fact, if you want to send a patch for the MAINTAINERS file to take over 
maintainership of the HSR/PRP driver, that would probably be a good thing.

(I'm CC'ing also Peter Heise to this conversation, since he's done some recent work 
on the HSR driver, and might want to keep updated.)


-- 
Arvid Brodin
Linux Consultant
ALTEN Sweden
