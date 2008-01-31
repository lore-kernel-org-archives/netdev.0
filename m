From: David Miller <davem@davemloft.net>
Subject: Re: [resend][PATCH] Introducing socket mark socket option
Date: Wed, 30 Jan 2008 19:08:26 -0800 (PST)
Message-ID: <20080130.190826.78596338.davem@davemloft.net>
References: <47974D07.5040202@trash.net>
	<1201167495912-git-send-email-panther@balabit.hu>
	<47985DD4.3000706@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47985DD4.3000706@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 24 Jan 2008 10:43:48 +0100

> Laszlo Attila Toth wrote:
> > A userspace program may wish to set the mark for each packets its send
> > without using the netfilter MARK target. Changing the mark can be used
> > for mark based routing without netfilter or for packet filtering.
> > 
> > It requires CAP_NET_ADMIN capability.
> 
> 
> Looks good to me.

Applied, thanks.
