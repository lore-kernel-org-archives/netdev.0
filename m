From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 0/8] mlxsw: Add IPv6 host dpipe table
Date: Wed, 30 Aug 2017 11:33:56 -0600
Message-ID: <4daaff3b-1e19-44db-308e-964d5c124f3b@gmail.com>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830172609.GD22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37157 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdH3Rd6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:33:58 -0400
Received: by mail-pg0-f65.google.com with SMTP id t193so5534290pgc.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:33:58 -0700 (PDT)
In-Reply-To: <20170830172609.GD22289@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/17 11:26 AM, Andrew Lunn wrote:
> On Wed, Aug 30, 2017 at 02:02:58PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Arkadi says:
>>
>> This patchset adds IPv6 host dpipe table support. This will provide the
>> ability to observe the hardware offloaded IPv6 neighbors.
> 
> Hi Jiri, Arkadi
> 
> Could you give us an example of the output seen in user space.
> 
> Thanks
> 	Andrew
> 

Posting iproute2 patches with the set would be helpful as well.
