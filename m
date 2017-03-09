From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc: smc911x: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 08 Mar 2017 22:05:59 -0800 (PST)
Message-ID: <20170308.220559.696949335364153997.davem@davemloft.net>
References: <1488322178-26972-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, a@unstable.cc, fw@strlen.de,
        robert.jarzmik@free.fr, arnd@arndb.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdCIGG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 01:06:27 -0500
In-Reply-To: <1488322178-26972-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 28 Feb 2017 23:49:38 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
