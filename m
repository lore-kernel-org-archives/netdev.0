From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: fix potential memory leak in xgbe-debugfs
Date: Mon, 05 Oct 2015 03:06:26 -0700 (PDT)
Message-ID: <20151005.030626.952511811755440522.davem@davemloft.net>
References: <636eed156113df40f9dd5e696f0486f428aff590.1443638366.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geliangtang@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <636eed156113df40f9dd5e696f0486f428aff590.1443638366.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@163.com>
Date: Wed, 30 Sep 2015 03:48:50 -0700

> Added kfree() to avoid the memory leak when debugfs_create_dir() fails.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Applied, thanks.
