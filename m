From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: pci: Fix the FW ready mask length
Date: Thu, 03 Nov 2016 16:21:46 -0400 (EDT)
Message-ID: <20161103.162146.380533087317700529.davem@davemloft.net>
References: <1478162515-2910-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758600AbcKCUVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:21:47 -0400
In-Reply-To: <1478162515-2910-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  3 Nov 2016 09:41:55 +0100

> From: Elad Raz <eladr@mellanox.com>
> 
> The system-status register is actually 16-bit wide and not 8 bit-wide.
> 
> Fixes: 233fa44bd67ae ("mlxsw: pci: Implement reset done check")
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
