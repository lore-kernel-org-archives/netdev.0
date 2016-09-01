From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] ipv6: add missing netconf notif when 'all'
 is updated
Date: Thu, 01 Sep 2016 15:18:40 -0700 (PDT)
Message-ID: <20160901.151840.1614788793469328588.davem@davemloft.net>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
        <1472544562-22581-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hideaki.yoshifuji@miraclelinux.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755240AbcIBTNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 15:13:49 -0400
In-Reply-To: <1472544562-22581-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 30 Aug 2016 10:09:21 +0200

> The 'default' value was not advertised.
> 
> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
