From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 11:05:50 -0400
Message-ID: <542823CE.9020301@mojatatu.com>
References: <5425A545.1040907@gmail.com> <5425ED2D.1000005@mojatatu.com> <5425F5CC.4070507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:54111 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbaI1PFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 11:05:53 -0400
Received: by mail-ie0-f180.google.com with SMTP id ar1so15025552iec.25
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 08:05:53 -0700 (PDT)
In-Reply-To: <5425F5CC.4070507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/14 19:25, John Fastabend wrote:
> On 09/26/2014 03:48 PM, Jamal Hadi Salim wrote:

>> Hrm  - poking inside there and this seems to be one of those
>> classifiers that hasnt been getting a lot of love. Doesnt
>> support actions well for example.
>>
>> It seems to work for me:
>
> This works for me as well try adding two or more policers and
> check if they all get printed.
>

Multiple actions wont work for this classifier. I have time,
will send patch.

cheers,
jamal
