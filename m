From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 00/16] net/sched rcu filters
Date: Fri, 12 Sep 2014 20:12:58 -0700
Message-ID: <5413B63A.4040806@gmail.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>  <20140912.223644.1321799741112871913.davem@davemloft.net> <1410576591.7106.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:39336 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaIMDNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:13:20 -0400
Received: by mail-ob0-f175.google.com with SMTP id vb8so123045obc.34
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:13:20 -0700 (PDT)
In-Reply-To: <1410576591.7106.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 07:49 PM, Eric Dumazet wrote:
> On Fri, 2014-09-12 at 22:36 -0400, David Miller wrote:
>> John you're getting really close with this series.
>>
>> Why don't you post everything up to the tc actions stuff,
>> which Eric has ACK'd already, and I can put that all into
>> the net-next tree right now.
>>
>> Then you can concentrate on the bits that remain without
>> having to post the other stuff over and over again.
>
>
> +2  ;)
>
>
>

Great. First round of 12 patches on the way.

Thanks for all the feedback/comments Eric.



-- 
John Fastabend         Intel Corporation
