From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Thu, 19 Jan 2017 13:39:41 +0200
Message-ID: <9498ff5d-7877-37b6-b72e-01d4bf40501a@mellanox.com>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
 <20170102195522.7488179b@griffin>
 <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
 <20170104103301.GA30008@penelope.horms.nl>
 <82df989f-09a7-a89a-a675-c45d190b049e@mellanox.com>
 <20170104125559.34a7b7ed@griffin> <20170118134103.351bd524@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, Simon Horman <simon.horman@netronome.com>,
        <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0065.outbound.protection.outlook.com ([104.47.1.65]:6976
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752378AbdASLjr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 06:39:47 -0500
In-Reply-To: <20170118134103.351bd524@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 18/01/2017 14:41, Jiri Benc wrote:
> On Wed, 4 Jan 2017 12:55:59 +0100, Jiri Benc wrote:
>> On Wed, 4 Jan 2017 13:51:13 +0200, Paul Blakey wrote:
>>> It mimics the kernel packing of flags, I have no problem either way
>>> (flags, or ip_flags/tcp_flags pairs), what do you think jiri?
>>
>> What Simon says makes sense to me. ip_flags and tcp_flags sounds like
>> the best solution so far (even better than my original suggestion).
>
> Is there any progress with the follow up patch? I don't think we want
> iproute2 with the magic numbers to be released.
>
> Thanks,
>
>  Jiri
>



Hi,
I've posted a patch:
"[PATCH iproute2 net-next] tc: flower: Refactor matching flags to be 
more user friendly"

Thanks,
Paul.
