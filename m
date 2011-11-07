From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] wanrouter: Remove kernel_lock annotations
Date: Mon, 07 Nov 2011 13:27:44 -0500 (EST)
Message-ID: <20111107.132744.1678311240740246318.davem@davemloft.net>
References: <1320654261-4473-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: richard@nod.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320654261-4473-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Mon,  7 Nov 2011 09:24:21 +0100

> The BKL is gone, these annotations are useless.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied, thanks Richard.
