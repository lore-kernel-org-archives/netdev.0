From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: remove unused fmt_long_hex
Date: Wed, 17 Feb 2016 16:22:50 -0500 (EST)
Message-ID: <20160217.162250.687968912783335215.davem@davemloft.net>
References: <1455576887-12157-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, sfeldma@gmail.com, john.r.fastabend@intel.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455576887-12157-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 15 Feb 2016 22:54:47 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Ever since commit 04ed3e741d0f133e02bed7fa5c98edba128f90e7
> ("net: change netdev->features to u32") the format string
> fmt_long_hex has not been used, so we may as well remove it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thank you.
