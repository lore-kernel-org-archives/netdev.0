From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 09/13] net: dsa: Remove support for MDB dump
 from DSA's drivers
Date: Mon, 7 Aug 2017 11:09:59 -0700
Message-ID: <72b4a3ed-13a0-440b-d19d-dc10aa287ee7@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-10-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:37122 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751857AbdHGSKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:10:02 -0400
Received: by mail-qt0-f195.google.com with SMTP id d10so1219201qtb.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:10:02 -0700 (PDT)
In-Reply-To: <1502025351-41261-10-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> This is done as a preparation before removing support for MDB dump from
> DSA core. The MDBs are synced with the bridge and thus there is no
> need for special dump operation support.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
