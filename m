From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [Intel-wired-lan] [jkirsher/net-queue PATCH] i40e: Add
 programming descriptors to cleaned_count
Date: Sat, 28 Oct 2017 00:21:20 +0200
Message-ID: <4b65ab35-b216-e13d-3676-03360bc5d47b@itcare.pl>
References: <20171022011222.12997.53593.stgit@localhost.localdomain>
 <1508695307.4970.32.camel@cohaesio.com>
 <003ecf6b-bd50-51fa-79a7-eab2b100257b@itcare.pl>
 <CABOTfnPBWaGhwpr8tBZ46piLqRR68LTyr=-cyj3kDESpuybjTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: Pavlos Parissis <pavlos.parissis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.iq.pl ([86.111.242.225]:47674 "EHLO smtp20.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdJ0WVV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 18:21:21 -0400
In-Reply-To: <CABOTfnPBWaGhwpr8tBZ46piLqRR68LTyr=-cyj3kDESpuybjTA@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from today it is in net.git

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/log/?qt=grep&q=i40e

It will be later in net-next


Also can You please tell me what firmware You are using with Your nics ?

Those are X710 ?


Thanks

Paweł



W dniu 2017-10-27 o 23:20, Pavlos Parissis pisze:
> On 23 October 2017 at 01:15, Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>> Yes can confirm that after adding patch:
>>
>> [jkirsher/net-queue PATCH] i40e: Add programming descriptors to
>> cleaned_count
>>
>>
>> There is no memleak.
>>
>>
> Somehow this patch isn't present in the current net-next repo.
> Shouldn't it be there?
>
> Cheers,
> Pavlos
>
