From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: intel: e1000: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 24 Jan 2017 13:50:06 -0500 (EST)
Message-ID: <20170124.135006.1371369423527179260.davem@davemloft.net>
References: <1485011163-7402-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdAXSuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:50:22 -0500
In-Reply-To: <1485011163-7402-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 21 Jan 2017 16:06:03 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

I am expecting the upstream Intel NIC folks to pick this up.
