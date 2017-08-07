From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 07/13] net: dsa: Remove support for vlan dump
 from DSA's drivers
Date: Mon, 7 Aug 2017 11:09:27 -0700
Message-ID: <987b0fdf-0931-cc3e-7fcf-7cdef530d380@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-8-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34924 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdHGSJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:09:30 -0400
Received: by mail-qt0-f195.google.com with SMTP id t37so1226885qtg.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:09:30 -0700 (PDT)
In-Reply-To: <1502025351-41261-8-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> This is done as a preparation before removing support for vlan dump from
> DSA core. The vlans are synced with the bridge and thus there is no
> need for special dump operation support.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
