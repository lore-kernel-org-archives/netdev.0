From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp.c
Date: Mon, 13 Jun 2005 18:11:55 -0700 (PDT)
Message-ID: <20050613.181155.63129744.davem@davemloft.net>
References: <m1fyvlbyp7.fsf@muc.de>
	<20050613.170045.74749212.davem@davemloft.net>
	<20050614001249.GF86745@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261239AbVFNBMR@vger.kernel.org>
To: ak@muc.de
In-Reply-To: <20050614001249.GF86745@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: 14 Jun 2005 02:12:49 +0200,Tue, 14 Jun 2005 02:12:49 +0200

> Ok I can fix it, but only reasonably after mem_init (at least without
> hacking up change_page_attr a lot to deal with bootmem).
> Is that still worth it? 

I think so.
