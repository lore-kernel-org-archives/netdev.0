From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipx: remove all unnecessary castings on
 ntohl
Date: Thu, 30 Oct 2014 15:52:40 -0400 (EDT)
Message-ID: <20141030.155240.619965312244569032.davem@davemloft.net>
References: <1414571502-9231-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414571502-9231-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 29 Oct 2014 09:31:42 +0100

> Apply commit e0f36310f793
> ("ipx: remove unnecessary casting on ntohl")
> to all seq_printf/08lX
> 
> Inspired-by: "David S. Miller" <davem@davemloft.net>
> Inspired-by: Joe Perches <joe@perches.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
