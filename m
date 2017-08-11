From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2/2] drivers: net: davinci_mdio: print bus frequency
Date: Fri, 11 Aug 2017 14:24:36 -0700 (PDT)
Message-ID: <20170811.142436.1877364176710679241.davem@davemloft.net>
References: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
        <1502351267-23841-2-git-send-email-muvarov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com
To: muvarov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdHKVYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:24:37 -0400
In-Reply-To: <1502351267-23841-2-git-send-email-muvarov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Uvarov <muvarov@gmail.com>
Date: Thu, 10 Aug 2017 10:47:47 +0300

> Frequency can be adjusted in DT it make sense to
> print current used value on driver init.
> 
> Signed-off-by: Max Uvarov <muvarov@gmail.com>

Applied to net-next.
