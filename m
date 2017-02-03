From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] Extract IFE logic to module
Date: Fri, 3 Feb 2017 08:02:18 -0500
Message-ID: <32c687d1-8966-f4ee-6e7f-80b7387c476e@mojatatu.com>
References: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
 <20170202101641.GA18828@penelope.horms.nl>
 <DB3PR05MB0764ACA552D008CADD09ED40AC4C0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Yotam Gigi <yotamg@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33971 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbdBCNCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:02:25 -0500
Received: by mail-io0-f174.google.com with SMTP id l66so16791599ioi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:02:25 -0800 (PST)
In-Reply-To: <DB3PR05MB0764ACA552D008CADD09ED40AC4C0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-02 06:12 AM, Yotam Gigi wrote:
>> -----Original Message-----

>>
>> I have no objection to this modularisation but I am curious to know
>> if you have a use-case in mind. My understanding is that earlier versions
>> of the sample action used IFE but that is not the case in the version that
>> was ultimately accepted.
>
> Hi Simon.
>
> You are right that the patches were done for the former version of the sample
> classifier, and there are not required for the current version. We don't have
> current use-case in mind, but I did send the patches because I think it can help
> others, or us in the future.

For what its worth given Yotam has done this work and vetted it and weve
reviewed and discussed it in the past, I am going to sign off on it.


cheers,
jamal
