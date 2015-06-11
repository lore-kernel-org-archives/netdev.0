From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Thu, 11 Jun 2015 10:32:42 -0500
Message-ID: <5579AA1A.80505@akamai.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>	<20150608.121601.1357405469784892473.davem@davemloft.net>	<m2mw08kx7b.wl@gmail.com>	<55783A1B.3070207@akamai.com>	<557854BB.1090605@linux-ipv6.org>	<5578B2C5.7080202@akamai.com> <m2eglil7ja.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:58198 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbbFKPcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 11:32:47 -0400
In-Reply-To: <m2eglil7ja.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2015 08:05 AM, Hajime Tazaki wrote:
>
> At Wed, 10 Jun 2015 16:57:25 -0500,
> Josh Hunt wrote:
>
>> Dave
>>
>> Can you please revert this change?
>>
>> commit 0243508edd317ff1fa63b495643a7c192fbfcd92
>> Author: Josh Hunt <johunt@akamai.com>
>> Date:   Mon Jun 8 12:00:59 2015 -0400
>>
>>       ipv6: Fix protocol resubmission
>>
>> Let me know if you need a patch to do this and I will submit something.
>>
>> I will fix the original issue in the UDP code in another patch.
>
> feel free to Cc me if you would like me to test the new patch.

I will definitely take you up on that :)

Thanks
Josh
