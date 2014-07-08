From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipconfig: add static to local variable
Date: Tue, 08 Jul 2014 11:30:51 -0700 (PDT)
Message-ID: <20140708.113051.27675403933376517.davem@davemloft.net>
References: <1404332540-5249-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404332540-5249-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  2 Jul 2014 22:22:20 +0200

> ic_dev_xid is only used in ipconfig.c
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied to net-next, thanks.
