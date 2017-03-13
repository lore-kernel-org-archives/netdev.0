From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: catc: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 15:26:35 -0700 (PDT)
Message-ID: <20170313.152635.720703857429128849.davem@davemloft.net>
References: <1489352906-13829-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdCMW0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:26:47 -0400
In-Reply-To: <1489352906-13829-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 12 Mar 2017 22:08:26 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
