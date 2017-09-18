From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tcp_input: Neaten DBGUNDO
Date: Mon, 18 Sep 2017 11:29:14 -0700 (PDT)
Message-ID: <20170918.112914.2210456285725452035.davem@davemloft.net>
References: <fcac7d078947b59e47ad4474d2c60d4fd3395bcd.1505095255.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fcac7d078947b59e47ad4474d2c60d4fd3395bcd.1505095255.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 10 Sep 2017 19:02:25 -0700

> Move the #ifdef into the static void function so that the use
> of DBGUNDO is validated when FASTRETRANS_DEBUG <= 1.
> 
> Remove the now unnecessary #else and #define DBGUNDO.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
