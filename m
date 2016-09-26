From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net v2 0/2] Fix tc-ife bugs
Date: Mon, 26 Sep 2016 05:55:49 -0400
Message-ID: <4131ab6a-5709-4f62-3cc6-138377361fec@mojatatu.com>
References: <1474806711-64660-1-git-send-email-yotamg@mellanox.com>
 <2b01c982-76b7-d380-807c-1fe1df62d285@mojatatu.com>
 <DB3PR05MB07647722715384C174CC52D2ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <098a8df2-aa3e-04a5-143b-a6946c9ece59@mojatatu.com>
 <a57bf1d3-0b6b-91fa-a57d-5b4a17f91959@mojatatu.com>
 <DB3PR05MB07641B3E085814C60BC60D64ACCD0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Yotam Gigi <yotamg@mellanox.com>, Yotam Gigi <yotam.gi@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:33297 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbcIZJzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:55:51 -0400
Received: by mail-it0-f41.google.com with SMTP id x192so12683300itb.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:55:51 -0700 (PDT)
In-Reply-To: <DB3PR05MB07641B3E085814C60BC60D64ACCD0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-26 03:01 AM, Yotam Gigi wrote:
>
>
>> -----Original Message-----
>> From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>> Sent: Monday, September 26, 2016 3:47 AM
>> To: Yotam Gigi <yotamg@mellanox.com>; Yotam Gigi <yotam.gi@gmail.com>;

[..]
>>> Yes please - Add NLA_HDRLEN to the dlen on the encode you showed above.
>
> OK. Did it and tested it. Everything seems functional.
>

Thank you. Please resend with this change and add my ACK to both
(I tested the first one)

>>>
>>
>> And the correct commit it fixes is:
>> a823f93750e341bc0d6829a00019435b96830fd4
>
> I can't find this commit. Where is it?
>
> Don't you mean that commit: 28a10c426e81afc88514bca8e73affccf850fdf6
> with title: "net sched: fix encoding to use real length"?
>

Sorry, yes that patch.

cheers,
jamal
