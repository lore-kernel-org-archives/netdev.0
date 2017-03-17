From: David Miller <davem@davemloft.net>
Subject: mlx5e backports for v4.9 -stable
Date: Thu, 16 Mar 2017 17:06:31 -0700 (PDT)
Message-ID: <20170316.170631.2026655873781156952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753465AbdCQAGe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 20:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commits:

====================
>From b0d4660b4cc52e6477ca3a43435351d565dfcedc Mon Sep 17 00:00:00 2001
From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 22 Feb 2017 17:20:14 +0200
Subject: [PATCH] net/mlx5e: Fix broken CQE compression initialization
====================

and

====================
>From 6dc4b54e77282caf17f0ff72aa32dd296037fbc0 Mon Sep 17 00:00:00 2001
From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 22 Feb 2017 17:20:15 +0200
Subject: [PATCH] net/mlx5e: Update MPWQE stride size when modifying CQE
 compress state
====================

do not apply even closely to v4.9 while I was working on -stable backports.

Please provide proper backports of these two patches if you want them to
show up in v4.9 -stable.

Thanks.
