From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/3] MAINTAINERS updates
Date: Tue, 30 May 2017 11:44:03 +0300
Message-ID: <1496133846-18343-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41281 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750998AbdE3Iop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 04:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains updates to the MAINTAINERS file.
In the first patch, I replace Yishai as the maintainer of
the mlx4_core driver.

In the other two patches we move an RDMA header file from
the list of the mlx4/mlx5 core driver into the respective
IB driver, where it belongs.

Series generated against net commit:
468b0df61a51 Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf

Thanks,
Tariq.

Tariq Toukan (3):
  MAINTAINERS: Update MELLANOX MLX4 core VPI driver maintainer
  MAINTAINERS: Move mlx4 rdma header file to IB driver charge
  MAINTAINERS: Move mlx5 rdma header file to IB driver charge

 MAINTAINERS | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
1.8.3.1
