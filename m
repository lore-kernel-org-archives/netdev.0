From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next FIX] RDMA/cma: Fix build breakage when infiniband
 is built-in
Date: Tue, 12 Nov 2013 10:14:59 +0200
Message-ID: <5281E383.1010009@mellanox.com>
References: <1384090080-1862-1-git-send-email-ogerlitz@mellanox.com>	<20131110.210355.1669362951389274888.davem@davemloft.net> <20131111.004319.58572524940129607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<eyalpe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:43783 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751595Ab3KLIQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 03:16:12 -0500
In-Reply-To: <20131111.004319.58572524940129607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2013 07:43, David Miller wrote:
> I really want to merge the net-next tree as soon as possible so I
> committed the following:
>
> ====================
> [PATCH] vlan: Implement vlan_dev_get_egress_qos_mask as an inline.
>
> This is to avoid very silly Kconfig dependencies for modules
> using this routine.
>
> Signed-off-by: David S. Miller<davem@davemloft.net>
Dave, I have checked it in our environment and things work as expected, 
thanks for taking care.

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
