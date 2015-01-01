From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Fix return value in qlcnic_probe()
Date: Wed, 31 Dec 2014 19:21:34 -0500 (EST)
Message-ID: <20141231.192134.2243740801309285028.davem@davemloft.net>
References: <1419926626-26624-1-git-send-email-xuyongjiande@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xuyongjiande@gmail.com
To: xuyongjiande@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419926626-26624-1-git-send-email-xuyongjiande@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xuyongjiande@163.com
Date: Tue, 30 Dec 2014 16:03:46 +0800

> From: Yongjian Xu <xuyongjiande@gmail.com>
> 
> If the check of adapter fails and goes into the 'else' branch, the
> return value 'err' should not still be zero.
> 
> Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>

Applied, thank you.
