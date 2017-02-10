From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] can: Fix kernel panic at security_sock_rcv_skb
Date: Fri, 10 Feb 2017 10:16:29 -0500 (EST)
Message-ID: <20170210.101629.2041075564534598861.davem@davemloft.net>
References: <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170129.183406.1410276231781823069.davem@davemloft.net>
        <9f8cc561-e1e6-c2f6-2bcc-3fe0282ca05c@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org,
        netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <9f8cc561-e1e6-c2f6-2bcc-3fe0282ca05c@hartkopp.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 10 Feb 2017 09:28:57 +0100

> can you please check whether this upstream commit
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f1712c73714088a7252d276a57126d56c7d37e64
> 
> really was queued up for -stable?

You never need to ask me this question, it is presented always, here:

	http://patchwork.ozlabs.org/bundle/davem/stable/?submitter=&state=*&q=&archive=

And it is indeed there.
