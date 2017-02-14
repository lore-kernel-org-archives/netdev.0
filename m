From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] sched: Fix accidental removal of errout goto
Date: Tue, 14 Feb 2017 11:44:49 -0500 (EST)
Message-ID: <20170214.114449.1152992861147187880.davem@davemloft.net>
References: <1487086033-5486-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753284AbdBNQov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:44:51 -0500
In-Reply-To: <1487086033-5486-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 14 Feb 2017 16:27:13 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Bring back the goto that was removed by accident.
> 
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Fixes: 40c81b25b16c ("sched: check negative err value to safe one level of indent")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
