From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dca: disable dca on IOAT ver.3.0 multiple-IOH platforms
Date: Fri, 17 Sep 2010 20:08:24 -0700 (PDT)
Message-ID: <20100917.200824.38076236.davem@davemloft.net>
References: <20100916160217.20315.35536.stgit@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: maciej.sosnowski@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100916160217.20315.35536.stgit@linux.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Date: Thu, 16 Sep 2010 18:02:26 +0200

> Direct Cache Access is not supported on IOAT ver.3.0 multiple-IOH platforms.
> This patch blocks registering of dca providers when multiple IOH detected with IOAT ver.3.0.
> 
> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>

Applied, thanks.
