From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/16] mlxsw: Add Infiniband support for
 Mellanox switches
Date: Sun, 30 Oct 2016 22:14:48 +0100
Message-ID: <20161030211448.GB21149@nanopsycho.orion>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <20161030.165107.1773338771250882750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36392 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753393AbcJ3VXl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:41 -0400
Received: by mail-wm0-f49.google.com with SMTP id p190so114452076wmp.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 14:23:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161030.165107.1773338771250882750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 30, 2016 at 09:51:07PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 28 Oct 2016 21:17:34 +0200
>
>> This patchset adds basic Infiniband support for SwitchX-2, Switch-IB
>> and Switch-IB-2 ASIC drivers.
>
>This depended upon the bug fixes which were only in 'net' until a few
>hours ago.
>
>Please state this explicitly in the future, it'll save me time.

Apologies. Will be more careful with this next time. Thanks.


>
>Series applied, thanks.
