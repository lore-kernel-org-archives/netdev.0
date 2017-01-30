From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] net: dsa: Port mirroring support
Date: Mon, 30 Jan 2017 15:36:06 -0500 (EST)
Message-ID: <20170130.153606.1116501695873263306.davem@davemloft.net>
References: <20170130043026.28867-1-f.fainelli@gmail.com>
        <182b4342-8e78-c2ce-eb25-ed39cb4ab50f@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754305AbdA3Upu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:45:50 -0500
In-Reply-To: <182b4342-8e78-c2ce-eb25-ed39cb4ab50f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 30 Jan 2017 12:32:59 -0800

> On 01/29/2017 08:30 PM, Florian Fainelli wrote:
>> Hi all,
>> 
>> This patch series adds support for port mirroring in the two
>> Broadcom switch drivers. The major part of the functional are actually with
>> the plumbing between tc and the drivers.
>> 
>> David, this will most likely conflict a little bit with my other series:
>>  net: dsa: bcm_sf2: CFP support, so just let me know if that happens, and
>> I will provide a rebased version. Thanks!
> 
> David, since you have applied the CFP series, there are few conflicts,
> will post a v5. Thanks!

Ok.  A lot of cross traffic in this area past few days :)
