From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: make msi-x different name for rx-tx
Date: Fri, 06 Feb 2009 01:31:20 -0800 (PST)
Message-ID: <20090206.013120.70515789.davem@davemloft.net>
References: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, akpm@linux-foundation.org,
	aabdulla@nvidia.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756616AbZBFJbg@vger.kernel.org>
In-Reply-To: <498BC3A8.9040203@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 05 Feb 2009 20:59:20 -0800

> 
> Impact: make /proc/interrupts could show more info which irq is rx or other for msi-x
> 
> add three name fields for rx, tx, other
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Applied to net-next-2.6
