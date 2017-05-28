From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add missing static to
 stub functions
Date: Sun, 28 May 2017 11:41:52 -0400 (EDT)
Message-ID: <20170528.114152.623491310137692319.davem@davemloft.net>
References: <1495985114-15339-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750794AbdE1PmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 11:42:11 -0400
In-Reply-To: <1495985114-15339-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 28 May 2017 17:25:14 +0200

> Stub functions in header files need to be static, or we can have
> multiple definitions errors.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 6335e9f2446b ("net: dsa: mv88e6xxx: mv88e6390X SERDES support")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
