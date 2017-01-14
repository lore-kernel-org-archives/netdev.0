From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sat, 14 Jan 2017 08:06:56 -0500
Message-ID: <825bbdf0-44e9-e960-74d1-76d7f6601de3@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <586ADAFE.1010105@gmail.com>
 <13dfd148-6a5b-cf62-b2b9-1c13e6d31155@mojatatu.com>
 <586B29A4.2060408@gmail.com>
 <92224e21-cd3c-26b0-d8a0-31a07268e553@mojatatu.com>
 <606f64cb-1744-d44f-8fd1-a4bdb1ca872f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Paul Blakey <paulb@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33584 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdANNHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 08:07:24 -0500
Received: by mail-io0-f196.google.com with SMTP id 101so8219300iom.0
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 05:06:59 -0800 (PST)
In-Reply-To: <606f64cb-1744-d44f-8fd1-a4bdb1ca872f@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-03 07:22 AM, Paul Blakey wrote:
>
> I don't mind having it on TC level but I didn't want to intervene with
> all filters/TC.
>

Please do make it for all classifiers. I described a use case for u32
where the cookie could be used to pretty print the output on a
dump/get.

cheers,
jamal
