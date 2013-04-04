From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Thu, 04 Apr 2013 08:58:58 -0700
Message-ID: <515DA342.5020503@intel.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com> <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Sagi Grimberg <sagig@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19179 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761627Ab3DDP66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 11:58:58 -0400
In-Reply-To: <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2013 7:26 AM, Or Gerlitz wrote:
> From: Sagi Grimberg <sagig@mellanox.com>
>
> The lldpad daemon queries the driver caps via the getcaps and getstate
> routines. Added the prpoer dbcnl_ops entries to support that.
>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---

Does lldpad work now with the mlx4_en driver?

Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
