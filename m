From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] net/mlx4: Avoid wrong virtual mappings
Date: Tue, 03 May 2016 12:00:32 -0400 (EDT)
Message-ID: <20160503.120032.1579415495628422336.davem@davemloft.net>
References: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
	<CAJ3xEMjomTc5JNNEknk-JMBUtvAcb5xY8La4zT4mKG2Ad=V85Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagaya@mellanox.com, netdev@vger.kernel.org, okaya@codeaurora.org,
	timur@codeaurora.org, eranbe@mellanox.com, yishaih@mellanox.com,
	talal@mellanox.com, saeedm@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933338AbcECQAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:00:37 -0400
In-Reply-To: <CAJ3xEMjomTc5JNNEknk-JMBUtvAcb5xY8La4zT4mKG2Ad=V85Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Tue, 3 May 2016 10:45:43 +0300

> The patch changes the driver to do single allocation for potentially
> very large HW WQE descriptor buffers such as those used by the RDMA
> (mlx5_ib) driver.

I know exactly what this patch does and how, but thanks for trying to
teach me what it does anyways.
