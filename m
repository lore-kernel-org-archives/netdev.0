From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio: Use netdev_<level> and pr_<level>
Date: Mon, 07 Jan 2013 19:41:19 -0800 (PST)
Message-ID: <20130107.194119.904344091925634365.davem@davemloft.net>
References: <1357515289.4940.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, dm@chelsio.com, leedom@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357515289.4940.6.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 06 Jan 2013 15:34:49 -0800

> Use more current logging styles.
> 
> Convert printks to pr_<level> and
> printks with ("%s: ...", dev->name to netdev_<level>(dev, "...
> 
> Add pr_fmt #defines where appropriate.
> Coalesce formats.
> Use pr_<level>_once where appropriate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
