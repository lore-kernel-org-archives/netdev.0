From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver/net: cosa driver uses udelay incorrectly
Date: Tue, 15 Apr 2014 00:09:25 -0400 (EDT)
Message-ID: <20140415.000925.88207717430881624.davem@davemloft.net>
References: <1397526791-4015-1-git-send-email-zhen-hual@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zhen-hual@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397526791-4015-1-git-send-email-zhen-hual@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Date: Tue, 15 Apr 2014 09:53:11 +0800

> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
> 
> In cosa driver, udelay with more than 20000 may cause __bad_udelay.
> Use msleep for instead.
> 
> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>

Applied, thank you.
