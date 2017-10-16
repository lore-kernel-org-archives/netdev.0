From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB Muli Pkey
 support 2017-10-11,Re: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB
 Muli Pkey support 2017-10-11
Date: Mon, 16 Oct 2017 05:45:03 +0100 (WEST)
Message-ID: <20171016.054503.459455425504112937.davem@davemloft.net>
References: <20171014184827.18491-1-saeedm@mellanox.com>
        <20171014184827.18491-1-saeedm@mellanox.com>
        <af28440c-bb1c-c47b-92dd-60bfbeaa839d@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, leonro@mellanox.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdJPEpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 00:45:10 -0400
In-Reply-To: <af28440c-bb1c-c47b-92dd-60bfbeaa839d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Sat, 14 Oct 2017 17:19:34 -0400

> On 10/14/2017 2:48 PM, Saeed Mahameed wrote:
>> Hi Dave and Doug,
>> 
>> This series includes updates for mlx5 IPoIB offloading driver from Alex
>> and Feras to add the support for Muli Pkey in the mlx5i ipoib offloading netdev,
>> to be merged into net-next and rdma-next trees.
> 
> As far as the two IPoIB patches are concerned, they're fine.
> 
>> Doug, I am sorry I couldn't base this on rc2 since the series needs and conflicts
>> with a fix that was submitted to rc3, so to keep things simple I based it on rc4,
>> I hope this is ok with you..
> 
> No worries, it just means I have to submit it under another branch.  But
> I'm already holding one patch series in a stand alone branch, so no big
> deal.  And, actually, the IPoIB changes are so small they can simply go
> through Dave's tree if you don't have any dependent code in the IPoIB
> driver to submit after this but still in this devel cycle.
> 
>> Please pull and let me know if there's any problem.
> 
> Once I hear that Dave is OK with the net changes, I'm ready to pull (if
> I need to).

They look fine and I've pulled this into net-next.

Thanks.
