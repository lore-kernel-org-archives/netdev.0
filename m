From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 2/2] tc: man: Add man entry for the matchall
 classifier.
Date: Wed, 31 Aug 2016 09:10:07 +0200
Message-ID: <20160831071007.GA1807@nanopsycho.orion>
References: <1472497261-2881-1-git-send-email-jiri@resnulli.us>
 <1472497261-2881-3-git-send-email-jiri@resnulli.us>
 <CAKoUArmn3uE1F7P_FDAfC+qQ1+RvzBden-yj8gzfO2ptK7F-6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yotamg@mellanox.com, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, Netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34540 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751299AbcHaHKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 03:10:11 -0400
Received: by mail-wm0-f66.google.com with SMTP id d196so2096622wmd.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 00:10:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKoUArmn3uE1F7P_FDAfC+qQ1+RvzBden-yj8gzfO2ptK7F-6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 30, 2016 at 08:00:12PM CEST, roszenrami@gmail.com wrote:
>Hi, Jiri,
>Only now could review this, so here are some slight comments:
>
>pacets->Should be packets.
>
>
>> +where the second command attaches a matchall filters on it that mirrors
>> the
>> +pacets to device eth2.
>>
>
>engress->Did you mean "egress" ?
>
>> +
>> +To create engress mirroring from port eth1 to port eth2:
>> +.EX
>> +
>>
>Again, pacets->Should be packets.

Will fix and send v3

>
>
>> +where the second command attaches a matchall filters on it that mirrors
>> the
>> +pacets to device eth2.
>> +
>> +
>>
>
>Regards,
>Rami Rosen
