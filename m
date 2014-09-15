From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 linux-next] net: fec: use container_of to resolve
 bufdesc_ex from bufdesc
Date: Mon, 15 Sep 2014 12:49:49 -0400 (EDT)
Message-ID: <20140915.124949.674650868038581883.davem@davemloft.net>
References: <1410640709-18295-1-git-send-email-fabf@skynet.be>
	<1410640709-18295-2-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410640709-18295-2-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Sat, 13 Sep 2014 22:38:26 +0200

> Use container_of instead of casting first structure member.
> 
> ARM cross-compiled but untested.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
