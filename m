From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] irda: add __init to irlan_open
Date: Tue, 30 Sep 2014 17:08:32 -0400 (EDT)
Message-ID: <20140930.170832.86783104041350738.davem@davemloft.net>
References: <1412108644-6547-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, samuel@sortiz.org,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412108644-6547-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 30 Sep 2014 22:24:04 +0200

> irlan_open is only called by __init irlan_init in same module.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
