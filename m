From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 07:50:09 +0100
Message-ID: <20110316065008.GA2780@psychotron.redhat.com>
References: <20110315.160124.104058374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@vger.kernel.org,
	linville@tuxdriver.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110315.160124.104058374.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Jiri, I know there is your patch set there, but I think you and Changli
>still need to go back and forth one more time wrt. orig_dev semantics.
>Since you have been posting this patch set for some time I'm still
>willing to apply it for this merge window, but please make haste and
>work out the remaining discussion.  Thank you.

Dave, you can apply the rest of the series and leave only the first
patch (af_packet) out. There's no dependency. We will figure out things
around origdev later.

Thanks.

Jirka
