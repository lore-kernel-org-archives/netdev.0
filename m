From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Use kasprintf
Date: Mon, 07 Jul 2014 17:00:55 -0700 (PDT)
Message-ID: <20140707.170055.1999993887924074843.davem@davemloft.net>
References: <20140628183628.GA9946@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140628183628.GA9946@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sun, 29 Jun 2014 00:06:29 +0530

> kasprintf combines kmalloc and sprintf, and takes care of the size
> calculation itself.
> 
> The semantic patch that makes this change is as follows:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied, thanks.
