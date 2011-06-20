From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Trivial]: ipv4, ping: Remove duplicate icmp.h include
Date: Mon, 20 Jun 2011 13:05:15 -0700 (PDT)
Message-ID: <20110620.130515.1956879930278498236.davem@davemloft.net>
References: <alpine.LNX.2.00.1106201028340.18991@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, segoon@openwall.com,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106201028340.18991@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Mon, 20 Jun 2011 10:31:20 +0200 (CEST)

> Remove the duplicate inclusion of net/icmp.h from net/ipv4/ping.c
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
