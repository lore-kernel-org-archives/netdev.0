From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/13] mlx4: order-0 allocations and page
 recycling
Date: Thu, 09 Mar 2017 09:52:10 -0800 (PST)
Message-ID: <20170309.095210.944048430889793477.davem@davemloft.net>
References: <e762e84a-07eb-428d-cb48-643fd4516cec@mellanox.com>
        <CANn89iLxDVfBs8FK9gXx0jj6CZGsFprDLfWjBUNeR3gKs-6=YQ@mail.gmail.com>
        <f15e06c4-719a-8c61-e893-16364e261d46@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, saeedm@mellanox.com,
        willemb@google.com, brouer@redhat.com, ast@kernel.org,
        eric.dumazet@gmail.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932164AbdCIRwN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 12:52:13 -0500
In-Reply-To: <f15e06c4-719a-8c61-e893-16364e261d46@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 9 Mar 2017 17:53:18 +0200

> 
> 
> On 09/03/2017 4:26 PM, Eric Dumazet wrote:
>> On Thu, Mar 9, 2017 at 5:49 AM, Tariq Toukan <tariqt@mellanox.com>
>> wrote:
>>
>>> Hi Eric,
>>>
>>> I was preparing this series for submission as well.
>>> You got it done first :)
>>>
>>> Thanks for re-submitting.
>>> I am Acking the patches now.
>>
>> I believe you also could have added a single Ack on this cover,
>> instead of one ack per element in the series.
> 
> I wasn't sure this is possible, I think patchworks doesn't recognize
> it.
> Dave, does this work?

If you ACK the cover letter, I add that ACK to the merge commit
for the patch series.  It is semantically equivalent to ACK'ing
the entire series.
