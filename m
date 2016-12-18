From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [PATCH iproute2 2/2] tc/m_tunnel_key: Add dest UDP port to tunnel
 key action
Date: Sun, 18 Dec 2016 09:41:15 +0200
Message-ID: <9ae06652-ba73-2451-556b-79548a949c05@mellanox.com>
References: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
 <1481616467-769-3-git-send-email-hadarh@mellanox.com>
 <20161215130335.GA30716@penelope.horms.nl>
 <20161215135312.GB7104@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amirva@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40067.outbound.protection.outlook.com ([40.107.4.67]:62745
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759582AbcLRNRj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 08:17:39 -0500
In-Reply-To: <20161215135312.GB7104@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/15/2016 3:53 PM, Simon Horman wrote:
> On Thu, Dec 15, 2016 at 02:03:36PM +0100, Simon Horman wrote:
>> On Tue, Dec 13, 2016 at 10:07:47AM +0200, Hadar Hen Zion wrote:
>>> Enhance tunnel key action parameters by adding destination UDP port.
>>>
>>> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>>> Reviewed-by: Roi Dayan <roid@mellanox.com>
>> Hi,
>>
>> this looks good to me but could you also update tc/m_tunnel_key.c:usage(); ?
> It seems that I was a bit hasty here as I now see that Stephen has
> indicated that he has applied this series. I also notice that
> patch 1/2 of this series also misses updating usage(). Let me know
> if sending some follow-up patches is the best way forwards.
Yes, I you are right, I'll send a follow-up patches.
Thanks,
Hadar
