From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 12/13] net: bridge: Remove FDB deletion
 through switchdev object
Date: Mon, 7 Aug 2017 11:12:11 -0700
Message-ID: <ae9a223c-c0a7-8910-25db-b82b98f6a54d@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:38217 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGSMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:12:18 -0400
Received: by mail-qt0-f195.google.com with SMTP id p3so1220126qtg.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:12:18 -0700 (PDT)
In-Reply-To: <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> At this point no driver supports FDB add/del through switchdev object
> but rather via notification chain, thus, it is removed.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
