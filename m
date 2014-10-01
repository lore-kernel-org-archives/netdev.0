From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] tcp: add __init to tcp_init_mem
Date: Wed, 01 Oct 2014 15:41:45 -0400 (EDT)
Message-ID: <20141001.154145.954072039606699747.davem@davemloft.net>
References: <1412180870-7599-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412180870-7599-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 18:27:50 +0200

> tcp_init_mem is only called by __init tcp_init.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thank you.
