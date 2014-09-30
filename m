From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] ieee802154: add __init to
 lowpan_frags_sysctl_register
Date: Tue, 30 Sep 2014 17:08:38 -0400 (EDT)
Message-ID: <20140930.170838.555234528916255681.davem@davemloft.net>
References: <1412109249-7432-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412109249-7432-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 30 Sep 2014 22:34:08 +0200

> lowpan_frags_sysctl_register is only called by __init lowpan_net_frag_init
> (part of the lowpan module).
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
