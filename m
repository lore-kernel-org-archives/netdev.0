From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,5/6] hyperv: Report actual status in receive
 completion packet
Date: Tue, 02 Oct 2012 14:42:28 -0400 (EDT)
Message-ID: <20121002.144228.2300646371090065994.davem@davemloft.net>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
	<1349191824-14001-5-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349191824-14001-5-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue,  2 Oct 2012 08:30:23 -0700

> The existing code always reports NVSP_STAT_SUCCESS. This patch adds the
> mechanism to report failure when it happens.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
