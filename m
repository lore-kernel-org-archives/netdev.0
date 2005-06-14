From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] net: fix sparse warning (plain int as NULL)
Date: Tue, 14 Jun 2005 18:39:58 +0200
Message-ID: <9a874849050614093925f95837@mail.gmail.com>
References: <Pine.LNX.4.62.0506122358570.16521@dragon.hyggekrogen.localhost>
	 <20050613.135950.48528369.davem@davemloft.net>
	 <9a8748490506131421707008ed@mail.gmail.com>
	 <20050613.143114.35469427.davem@davemloft.net>
Reply-To: Jesper Juhl <jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: juhl-lkml@dif.dk, linux-kernel@vger.kernel.org,
	ross.biro@gmail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261247AbVFNQkZ@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050613.143114.35469427.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/05, David S. Miller <davem@davemloft.net> wrote:
> From: Jesper Juhl <jesper.juhl@gmail.com>
> Date: Mon, 13 Jun 2005 23:21:56 +0200
> 
> > Since tcp_ack_saw_tstamp() in 2.6.12-rc6-git6 only takes two arguments
> > this patch is only relevant for -mm.
> 
> Thanks for the clarification.
> 
You are welcome. Should I just send the patch on to Andrew for inclusion, or?

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
