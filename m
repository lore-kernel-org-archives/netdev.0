From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] - drivers/net/ppp_* - remove ptr comparisons to 0
Date: Mon, 12 Nov 2007 18:07:41 -0800 (PST)
Message-ID: <20071112.180741.31880713.davem@davemloft.net>
References: <1194910431.9407.53.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org
To: joe@perches.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1194910431.9407.53.camel@localhost>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 12 Nov 2007 15:33:51 -0800

> fix sparse warnings "Using plain integer as NULL pointer"
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
