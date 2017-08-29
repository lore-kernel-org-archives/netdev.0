From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 14:52:03 -0700 (PDT)
Message-ID: <20170829.145203.2052260546778215324.davem@davemloft.net>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
        <20170829.144254.740239595444825239.davem@davemloft.net>
        <d8ae99de-398d-f314-309f-50c36df9240a@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdH2VwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:52:05 -0400
In-Reply-To: <d8ae99de-398d-f314-309f-50c36df9240a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Aug 2017 14:45:30 -0700

> On 08/29/2017 02:42 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue, 29 Aug 2017 11:39:41 -0700
>> 
>>> While trying an ARM BE kernel for kinks, the 3 drivers below started not
>>> working and the reasons why became pretty obvious because the register space
>>> remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
>>> native endian (let's call that a feature).
>> 
>> Series applied, thanks Florian.
> 
> If you have not pushed yet, seems like not, can you check you applied v2
> of this patch series, in particular this patch:
> 
> http://patchwork.ozlabs.org/patch/807296/

If you didn't keep messing with the patchwork state of patches in my
queue this confusion would not have happened.

I did happen to apply v2, but because of all of the confusion you keep
creating, I used the header message from v1.

It's already pushed out so there is nothing we can do about it.
