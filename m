From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Remove uses of return value of seq_printf
Date: Fri, 20 Feb 2015 15:18:43 -0500 (EST)
Message-ID: <20150220.151843.902196140727344622.davem@davemloft.net>
References: <1424136699.8287.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mareklindner@neomailbox.ch, antonio@meshcoding.com,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424136699.8287.10.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 16 Feb 2015 17:31:39 -0800

> This function is soon going to return void so remove the
> return value use.
> 
> Convert the return value to test seq_has_overflowed() instead.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next.
