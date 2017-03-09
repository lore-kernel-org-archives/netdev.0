From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 00/13] mlx4: order-0 allocations and page
 recycling
Date: Thu, 9 Mar 2017 17:53:18 +0200
Message-ID: <f15e06c4-719a-8c61-e893-16364e261d46@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <e762e84a-07eb-428d-cb48-643fd4516cec@mellanox.com>
 <CANn89iLxDVfBs8FK9gXx0jj6CZGsFprDLfWjBUNeR3gKs-6=YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:57504
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932497AbdCIPx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 10:53:28 -0500
In-Reply-To: <CANn89iLxDVfBs8FK9gXx0jj6CZGsFprDLfWjBUNeR3gKs-6=YQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/03/2017 4:26 PM, Eric Dumazet wrote:
> On Thu, Mar 9, 2017 at 5:49 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>
>> Hi Eric,
>>
>> I was preparing this series for submission as well.
>> You got it done first :)
>>
>> Thanks for re-submitting.
>> I am Acking the patches now.
>
> I believe you also could have added a single Ack on this cover,
> instead of one ack per element in the series.

I wasn't sure this is possible, I think patchworks doesn't recognize it.
Dave, does this work?

>
> David can you tell us if this is true ?
>
> Thanks Tariq !
>

You're welcome.
