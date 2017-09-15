From: Pierre Colombier <pierre@abeille.com>
Subject: Re: feature request for kernel module 8021q
Date: Fri, 15 Sep 2017 15:02:04 +0200
Message-ID: <80283eea-3f4a-1548-9d62-1387c5f08712@abeille.com>
References: <c010d65d-3050-8d88-22aa-cac092dd3904@abeille.com>
 <A4D84B7F-5D4A-44C8-875C-C113D7C5C688@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.abeille.com ([212.129.23.178]:35801 "EHLO
        mail3.abeille.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdIONCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 09:02:06 -0400
In-Reply-To: <A4D84B7F-5D4A-44C8-875C-C113D7C5C688@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> One interesting feature would be to have a special vlan number
>>
>> (let's say 0 or -1 or 4097 ) designed so that it gets all the untagged
>> trafic and only the untagged trafic.
> 4097 is not a valid number nor is -1 since that closely follows what the VLAN ID extracted from the tag would be. VLAN 0 is more or less the untagged VLAN.
I know -1 or 4097 are invalid numbers
This is precicely why i suggested them as "special"
I wasn't aware of the existing Vlan 0 feature
I just tried again and it seems to be exactly what I was requesting.

What do you mean by "more or less" ?
