From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] lib: Remove string from parman config selection
Date: Thu, 23 Feb 2017 10:55:25 -0500 (EST)
Message-ID: <20170223.105525.1750668203966263569.davem@davemloft.net>
References: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbdBWPzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:55:33 -0500
In-Reply-To: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Feb 2017 10:57:45 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> As reported by Geert, remove the string so the user does not see this
> config option. The option is explicitly selected only as a dependency of
> in-kernel users.
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
