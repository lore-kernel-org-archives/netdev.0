From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: can: replace strict_strtoul() with kstrtoul()
Date: Mon, 03 Jun 2013 00:41:01 -0700 (PDT)
Message-ID: <20130603.004101.128796510964117586.davem@davemloft.net>
References: <000d01ce5e98$46b6d430$d4247c90$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, wg@grandegger.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <000d01ce5e98$46b6d430$d4247c90$@samsung.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jingoo Han <jg1.han@samsung.com>
Date: Sat, 01 Jun 2013 16:18:55 +0900

> The usage of strict_strtoul() is not preferred, because
> strict_strtoul() is obsolete. Thus, kstrtoul() should be
> used.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
