From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH linux-next v4] mlx5: wrong page mask if CONFIG_ARCH_DMA_ADDR_T_64BIT
 enabled for 32Bit architectures
Date: Wed, 15 Apr 2015 10:11:51 +0300
Message-ID: <552E0F37.2080509@mellanox.com>
References: <1429078919-28122-1-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Honggang Li <honli@redhat.com>, <eli@mellanox.com>,
	<netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0063.outbound.protection.outlook.com ([157.55.234.63]:60480
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752002AbbDOHMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 03:12:08 -0400
In-Reply-To: <1429078919-28122-1-git-send-email-honli@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/2015 9:21 AM, Honggang Li wrote:
> Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host page size to firmware')
>
> Signed-off-by: Honggang Li<honli@redhat.com>
ain't over... avoid the blank line between the Fixes tag to your SOB
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
