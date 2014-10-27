From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] ipx: remove __inline__ in c file on static
Date: Mon, 27 Oct 2014 16:25:54 -0400 (EDT)
Message-ID: <20141027.162554.1582020588592240837.davem@davemloft.net>
References: <1414440728-6144-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414440728-6144-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 27 Oct 2014 21:12:08 +0100

> Let compiler decide what to do with static void __ipxitf_put()
> 
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> V2: remove __inline__ instead of replacing it by standard inline
> (suggested by David S. Miller)

Applied, thanks Fabian.
