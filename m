From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: micrel: ks8851: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 22:34:18 -0500 (EST)
Message-ID: <20170212.223418.1416541597042959247.davem@davemloft.net>
References: <1486630667-31935-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, stephen.boyd@linaro.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdBMDeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 22:34:25 -0500
In-Reply-To: <1486630667-31935-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu,  9 Feb 2017 09:57:47 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
