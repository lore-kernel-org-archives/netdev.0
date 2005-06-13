From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: fix sparse warning (plain int as NULL)
Date: Mon, 13 Jun 2005 14:31:14 -0700 (PDT)
Message-ID: <20050613.143114.35469427.davem@davemloft.net>
References: <Pine.LNX.4.62.0506122358570.16521@dragon.hyggekrogen.localhost>
	<20050613.135950.48528369.davem@davemloft.net>
	<9a8748490506131421707008ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: juhl-lkml@dif.dk, linux-kernel@vger.kernel.org,
	ross.biro@gmail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261402AbVFMVdr@vger.kernel.org>
To: jesper.juhl@gmail.com
In-Reply-To: <9a8748490506131421707008ed@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Mon, 13 Jun 2005 23:21:56 +0200

> Since tcp_ack_saw_tstamp() in 2.6.12-rc6-git6 only takes two arguments
> this patch is only relevant for -mm.

Thanks for the clarification.
