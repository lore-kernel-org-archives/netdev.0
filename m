From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH ethtool v3 1/2] ethtool-copy.h:sync with net
Date: Mon, 21 Nov 2016 17:03:56 -0800
Message-ID: <2ef46dcf-94ba-73fd-3e35-d82b5ec5d841@gmail.com>
References: <1479384480-31201-1-git-send-email-allan.nielsen@microsemi.com>
 <1479384480-31201-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34821 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753951AbcKVBEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 20:04:01 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so176817pfk.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 17:04:00 -0800 (PST)
In-Reply-To: <1479384480-31201-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 04:07 AM, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> This covers kernel changes upto:
> 
> commit f5a4732f85613b3fb43f8bc33a017e3db3b3605a
> Author: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Date:   Wed Nov 9 16:33:09 2016 +0530
> 
>     ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
> 
>     For operation in cabling environments that are incompatible with
>     1000BASE-T, PHY device may provide an automatic link speed downshift
>     operation. When enabled, the device automatically changes its 1000BASE-T
>     auto-negotiation to the next slower speed after a configured number of
>     failed attempts at 1000BASE-T.  This feature is useful in setting up in
>     networks using older cable installations that include only pairs A and B,
>     and not pairs C and D.
> 
>     Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
>     Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
