From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 01/12] net: dsa: Change DSA slave FDB API to
 be switchdev independent
Date: Wed, 5 Jul 2017 12:13:20 -0700
Message-ID: <16eefa22-552d-9c75-27bb-b138869b222e@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-2-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36224 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752092AbdGETN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:13:26 -0400
Received: by mail-wr0-f196.google.com with SMTP id 77so50878976wrb.3
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:13:26 -0700 (PDT)
In-Reply-To: <1499268990-19251-2-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> In order to support FDB add/del to be on a notifier chain the slave
> API need to be changed to be switchdev independent.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
