From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 0/4] net: dsa: Port mirroring support
Date: Sun, 29 Jan 2017 12:33:53 -0800
Message-ID: <cf7b8630-d743-544d-b43b-2576d5edf5fd@gmail.com>
References: <20170129192910.6069-1-f.fainelli@gmail.com>
 <c6533daa-c036-6aef-1850-773996533ccc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        cphealy@gmail.com, jiri@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33878 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdA2Ud5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 15:33:57 -0500
Received: by mail-oi0-f68.google.com with SMTP id w144so24521258oiw.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 12:33:56 -0800 (PST)
In-Reply-To: <c6533daa-c036-6aef-1850-773996533ccc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/29/2017 11:46 AM, Florian Fainelli wrote:
> On 01/29/2017 11:29 AM, Florian Fainelli wrote:
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
> David, not sure why but patch 1 does not want to show up on patchwork,
> and cross checking with spinics.net it's not on netdev@vger.kernel.org
> either... you should have it in your inbox hopefully. git send-email did
> return it was sent correctly. Let me know if you need me to resend the
> whole series. Thanks!

Seems to have appeared on patchwork now, mark the duplicate as
superseded. Thanks
-- 
Florian
