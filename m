From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix VF register on vlan devices
Date: Fri, 03 Jun 2016 19:40:25 -0400 (EDT)
Message-ID: <20160603.194025.204471233386993382.davem@davemloft.net>
References: <1464894124-11450-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464894124-11450-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu,  2 Jun 2016 12:02:04 -0700

> Added a condition to avoid vlan devices with same MAC registering
> as VF.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
