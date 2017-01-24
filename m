From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Tue, 24 Jan 2017 13:08:03 -0500
Message-ID: <8760l4nxfg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com> <20170120.141705.1390880809796992457.davem@davemloft.net> <87r33s2ynp.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, nadavh@marvell.com,
        dingwei@marvell.com, kostap@marvell.com, shjzhou@marvell.com,
        jpannell@marvell.com
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47472 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdAXSIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:08:35 -0500
In-Reply-To: <87r33s2ynp.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> Hi David,
>  
>  On ven., janv. 20 2017, David Miller <davem@davemloft.net> wrote:
>
>> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> Date: Thu, 19 Jan 2017 22:49:32 +0100
>>
>>> I created a new family for this switch and filled the ops structure
>>> by selecting which seems the more appropriate functions. I rebased
>>> the series on net-next/master which allowed me to benefit to the
>>> eeprom functions introduced for the 6390.
>>
>> It looks like there will be at least one more respin of this series,
>> specifically to remove the new family as Vivien seems to object to
>> this.
>
> I am about to send a new version. However about removing the new family,
> I thought that with the confirmation from Andrew we could keep it.
>
> Vivien could you confirm this?

I confirm.

Thanks!

        Vivien
