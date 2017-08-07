From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 10/13] net: dsa: Remove redundant MDB dump
 support
Date: Mon, 7 Aug 2017 11:04:07 -0700
Message-ID: <ffe7480b-5f26-456b-533d-1c9325adab2c@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-11-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33420 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdHGSEK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:04:10 -0400
Received: by mail-qt0-f193.google.com with SMTP id u19so1226733qtc.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:04:10 -0700 (PDT)
In-Reply-To: <1502025351-41261-11-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> Currently the MDB HW database is synced with the bridge's one, thus,
> There is no need to support special dump functionality.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
