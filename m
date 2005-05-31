From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [PKT_SCHED] Logic simplifications and
 codingstyle/whitespace cleanups
Date: Tue, 31 May 2005 15:30:08 -0700 (PDT)
Message-ID: <20050531.153008.112289363.davem@davemloft.net>
References: <20050527145002.GR15391@postel.suug.ch>
	<20050527145611.GY15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050527145611.GY15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, I did something tricky to make this all work out and
put the changes in the correct tree cleanly.

I put patches 1-3 into my main net-2.6 tree, they will go to Linus
shortly.  Patches 4-7 I put into my net-2.6.13 tree after merging
in the net-2.6 tree (and thus patches 1-3).

I pushed it out to kernel.org, and it should show up on all the
mirrors and the GIT website shortly.

Thanks.
