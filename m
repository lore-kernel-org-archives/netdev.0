From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net/dsa/dsa.c: remove unnecessary null test before
 kfree
Date: Wed, 25 Jun 2014 16:15:34 -0700 (PDT)
Message-ID: <20140625.161534.2268236653961314658.davem@davemloft.net>
References: <1403544767-12438-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, grant.likely@linaro.org,
	netdev@vger.kernel.org, joe@perches.com
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403544767-12438-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 23 Jun 2014 19:32:47 +0200

> Fix checkpatch warning:
> WARNING: kfree(NULL) is safe this check is probably not required
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: netdev@vger.kernel.org
> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks.
