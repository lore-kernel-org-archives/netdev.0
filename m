From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 05/13] net: dsa: Move FDB add/del
 implementation inside DSA
Date: Mon, 7 Aug 2017 11:08:19 -0700
Message-ID: <fe72567c-ff0e-1825-7dc0-46d9adefbee7@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-6-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:37192 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdHGSIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:08:24 -0400
Received: by mail-qk0-f194.google.com with SMTP id x77so1164200qka.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:08:23 -0700 (PDT)
In-Reply-To: <1502025351-41261-6-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> Currently DSA uses switchdev's implementation of FDB add/del ndos. This
> patch moves the implementation inside DSA in order to support the legacy
> way for static FDB configuration.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
