From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 06/13] net: dsa: Add support for querying
 supported bridge flags
Date: Mon, 7 Aug 2017 11:01:53 -0700
Message-ID: <5d2104ba-6b27-3b6e-8206-dab197a1a50e@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-7-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33631 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGSB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:01:56 -0400
Received: by mail-qk0-f193.google.com with SMTP id d145so1169206qkc.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:01:56 -0700 (PDT)
In-Reply-To: <1502025351-41261-7-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> The DSA drivers do not support bridge flags offload. Yet, this attribute
> should be added in order for the bridge to fail when one tries set a
> flag on the port, as explained in commit dc0ecabd6231 ("net: switchdev:
> Add support for querying supported bridge flags by hardware").
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
