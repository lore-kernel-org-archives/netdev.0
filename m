From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 20:41:42 -0400 (EDT)
Message-ID: <20130422.204142.498231678158708544.davem@davemloft.net>
References: <20130422130324.43b4521c6b4719ed7a96ef00@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	nanditad@google.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130422130324.43b4521c6b4719ed7a96ef00@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 22 Apr 2013 13:03:24 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/ipv4/tcp_input.c between commit 12fb3dd9dc3c ("tcp: call
> tcp_replace_ts_recent() from tcp_ack()") from Linus' tree and commit
> 9b717a8d2450 ("tcp: TLP loss detection") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

I took care of this during the net --> net-next merge, thanks!
