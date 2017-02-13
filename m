From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: natsemi: ns83820: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 22:35:06 -0500 (EST)
Message-ID: <20170212.223506.544191440339326357.davem@davemloft.net>
References: <1486767468-20242-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, weiyongjun1@huawei.com, javier@osg.samsung.com,
        netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdBMDfZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 22:35:25 -0500
In-Reply-To: <1486767468-20242-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 10 Feb 2017 23:57:48 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
