From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Don't build unused suspend/resume functions not enabled
Date: Fri, 11 Apr 2014 16:50:06 -0400 (EDT)
Message-ID: <20140411.165006.1694951753458959411.davem@davemloft.net>
References: <1397204066-7389-1-git-send-email-daniel@quora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: daniel@quora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397204066-7389-1-git-send-email-daniel@quora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel J Blueman <daniel@quora.org>
Date: Fri, 11 Apr 2014 16:14:26 +0800

> When CONFIG_PM_SLEEP isn't enabled, bnx2_suspend/resume are unused; don't
> build them when they aren't used.
> 
> Signed-off-by: Daniel J Blueman <daniel@quora.org>

Applied, thank you.
