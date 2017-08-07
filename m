From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 12/13] net: bridge: Remove FDB deletion
 through switchdev object
Date: Mon, 7 Aug 2017 12:36:55 +0200
Message-ID: <20170807103655.GD2085@nanopsycho.orion>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:37688 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752606AbdHGKg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 06:36:58 -0400
Received: by mail-wr0-f177.google.com with SMTP id 33so150289wrz.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 03:36:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Aug 06, 2017 at 03:15:50PM CEST, arkadis@mellanox.com wrote:
>At this point no driver supports FDB add/del through switchdev object
>but rather via notification chain, thus, it is removed.
>
>Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
