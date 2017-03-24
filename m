From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 0/5] net:ethernet:aquantia: Misc fixes for
 atlantic driver.
Date: Fri, 24 Mar 2017 12:33:33 -0700 (PDT)
Message-ID: <20170324.123333.202342389645073925.davem@davemloft.net>
References: <cover.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967054AbdCXTdp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:33:45 -0400
In-Reply-To: <cover.1490267633.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Thu, 23 Mar 2017 14:19:40 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> The following patchset containg several fixes for aQuantia AQtion driver
> for net tree: A couple fixes for IPv6 and other fixes.
> 
> v1->v2: Fix compilation error (using HW_ATL_A0_TXD_CTL_CMD_IPV6 instead
>         HW_ATL_B0_TXD_CTL_CMD_IPV6).
> v2->v3: Added "Fixes" tags.

Series applied, thanks.
