From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/2] Extract IFE logic to module
Date: Fri, 3 Feb 2017 16:29:10 +0100
Message-ID: <CAJqx_nziZGh2Wn1Q=KEpWeHZ9m-pNbp2_JGiK3zvuBSOsdRzcA@mail.gmail.com>
References: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
 <20170202101641.GA18828@penelope.horms.nl> <DB3PR05MB0764ACA552D008CADD09ED40AC4C0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <32c687d1-8966-f4ee-6e7f-80b7387c476e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yotam Gigi <yotamg@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35096 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBCP3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 10:29:13 -0500
Received: by mail-lf0-f44.google.com with SMTP id n124so11912460lfd.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 07:29:12 -0800 (PST)
In-Reply-To: <32c687d1-8966-f4ee-6e7f-80b7387c476e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No objections here.

On Fri, Feb 3, 2017 at 2:02 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 17-02-02 06:12 AM, Yotam Gigi wrote:
>>>
>>> -----Original Message-----
>
>
>>>
>>> I have no objection to this modularisation but I am curious to know
>>> if you have a use-case in mind. My understanding is that earlier versions
>>> of the sample action used IFE but that is not the case in the version
>>> that
>>> was ultimately accepted.
>>
>>
>> Hi Simon.
>>
>> You are right that the patches were done for the former version of the
>> sample
>> classifier, and there are not required for the current version. We don't
>> have
>> current use-case in mind, but I did send the patches because I think it
>> can help
>> others, or us in the future.
>
>
> For what its worth given Yotam has done this work and vetted it and weve
> reviewed and discussed it in the past, I am going to sign off on it.
>
>
> cheers,
> jamal
>
