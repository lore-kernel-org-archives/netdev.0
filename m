From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: allow reception of large (>1518 bytes) frames
Date: Wed, 07 Apr 2010 21:53:49 -0700 (PDT)
Message-ID: <20100407.215349.39367977.davem@davemloft.net>
References: <1270652389-5364-1-git-send-email-peter.korsgaard@barco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haavard.skinnemoen@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peter.korsgaard@barco.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270652389-5364-1-git-send-email-peter.korsgaard@barco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Korsgaard <peter.korsgaard@barco.com>
Date: Wed,  7 Apr 2010 16:59:49 +0200

> Enable BIG bit in the network configuration register, so the MAC doesn't
> reject big frames (E.G. when vlans are used).
> 
> Signed-off-by: Peter Korsgaard <peter.korsgaard@barco.com>

Applied to net-next-2.6, thanks.
