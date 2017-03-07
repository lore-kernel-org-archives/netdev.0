From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sis: sis900: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 06 Mar 2017 17:08:04 -0800 (PST)
Message-ID: <20170306.170804.621548132942177012.davem@davemloft.net>
References: <1488233857-24171-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754299AbdCGBOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:14:38 -0500
In-Reply-To: <1488233857-24171-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 27 Feb 2017 23:17:37 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
