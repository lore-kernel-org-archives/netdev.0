From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netpoll: warning for ndo_start_xmit returns with
 interrupts enabled
Date: Sun, 23 Aug 2009 19:50:01 -0700 (PDT)
Message-ID: <20090823.195001.129946655.davem@davemloft.net>
References: <1250861616.24178.20.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, nico@cam.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jason.wessel@windriver.com
To: Dongdong.deng@windriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751353AbZHXCtu@vger.kernel.org>
In-Reply-To: <1250861616.24178.20.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: DDD <Dongdong.deng@windriver.com>
Date: Fri, 21 Aug 2009 21:33:36 +0800

> WARN_ONCE for ndo_start_xmit() enable interrupts in netpoll_send_skb(),
> because the NETPOLL API requires that interrupts remain disabled in
> netpoll_send_skb().
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>

Applied.
