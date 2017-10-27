From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/4] Mellanox, mlx5 fixes 2017-10-26
Date: Fri, 27 Oct 2017 22:25:39 +0900 (KST)
Message-ID: <20171027.222539.127562215367302641.davem@davemloft.net>
References: <20171026075937.26477-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751908AbdJ0NZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:25:44 -0400
In-Reply-To: <20171026075937.26477-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 26 Oct 2017 00:59:33 -0700

> The series includes some misc fixes for mlx5 core and etherent driver.
> Please pull and let me know if there's any problem.

Pulled.

> For -Stable:
> net/mlx5e: Properly deal with encap flows add/del under neigh update (kernels >= 4.12)
> net/mlx5: Fix health work queue spin lock to IRQ safe  (kernels >= 4.13)

Queued up for -stable.

Thank you very much!
