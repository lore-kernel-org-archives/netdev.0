From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 PATCH v3 1/1] tc: introduce IFE action
Date: Sat, 7 May 2016 09:11:36 -0400
Message-ID: <572DE988.8060702@mojatatu.com>
References: <1461274814-16235-1-git-send-email-jhs@emojatatu.com>
 <20160422100047.083055ee@xeon-e3> <571E0D68.1050106@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34994 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbcEGNLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 09:11:39 -0400
Received: by mail-io0-f196.google.com with SMTP id u185so16716804iod.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 06:11:38 -0700 (PDT)
In-Reply-To: <571E0D68.1050106@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-25 08:28 AM, Jamal Hadi Salim wrote:
> On 16-04-22 01:00 PM, Stephen Hemminger wrote:
>> On Thu, 21 Apr 2016 17:40:14 -0400
>
>>
>> All header files for iproute2 (in include/linux) should come from
>> santized kernel
>> headers. I do not see the file tc_ife.h in include/uapi/linux in
>> current net-next
>> kernel source tree.
>>
>
> I am assuming based on your other email this is taken care of?


your patch didnt make it. I have time - will take care of this.

cheers,
jamal
