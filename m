From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: make dsa_pack_type static
Date: Mon, 01 Sep 2014 20:42:20 -0700 (PDT)
Message-ID: <20140901.204220.875089324891708249.davem@davemloft.net>
References: <1409341327-22527-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbaIBDmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 23:42:21 -0400
In-Reply-To: <1409341327-22527-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 29 Aug 2014 12:42:07 -0700

> net/dsa/dsa.c:624:20: sparse: symbol 'dsa_pack_type' was not declared.
> Should it be static?
> 
> Fixes: 3e8a72d1dae374 ("net: dsa: reduce number of protocol hooks")
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
