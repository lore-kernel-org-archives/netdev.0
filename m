From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: unregister nf hooks, matches and targets in
 the reverse order
Date: Wed, 15 Sep 2010 19:32:43 +0200
Message-ID: <4C91033B.6070902@trash.net>
References: <1283436908-10744-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1283436908-10744-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 02.09.2010 16:15, schrieb Changli Gao:
> Since we register nf hooks, matches and targets in order, we'd better
> unregister them in the reverse order.

Why? Is there a specific bug you've noticed?
