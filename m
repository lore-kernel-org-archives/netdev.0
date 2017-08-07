From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 08/13] net: dsa: Remove support for bypass
 bridge port attributes/vlan set
Date: Mon, 7 Aug 2017 11:09:44 -0700
Message-ID: <3248e274-0d5b-2cf6-32fe-3c494ec5063d@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-9-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36085 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGSJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:09:47 -0400
Received: by mail-qt0-f196.google.com with SMTP id c15so1232298qta.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:09:47 -0700 (PDT)
In-Reply-To: <1502025351-41261-9-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> The bridge port attributes/vlan for DSA devices should be set only
> from bridge code. Furthermore, The vlans are synced totally with the
> bridge so there is no need for special dump support.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
