From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Fri, 17 Jun 2016 09:00:09 -0700
Message-ID: <20160617160007.GA52082@ast-mbp.thefacebook.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35339 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcFQQAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:00:19 -0400
Received: by mail-pa0-f67.google.com with SMTP id hf6so6056266pac.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 09:00:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 05:43:53PM +0300, Saeed Mahameed wrote:
> From: Maor Gottlieb <maorg@mellanox.com>
> 
> Add kernel offload flow tag for packets that will bypass the kernel
> stack, e.g (RoCE/RDMA/RAW ETH (DPDK), etc ..).

so the whole series is an elaborate way to enable dpdk? how nice.
NACK.
