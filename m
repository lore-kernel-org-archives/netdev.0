From: David Miller <davem@davemloft.net>
Subject: Re: [for-next V2 00/17][PULL request] Mellanox mlx5 core driver
 updates 2016-08-20
Date: Mon, 22 Aug 2016 11:49:01 -0700 (PDT)
Message-ID: <20160822.114901.1630384348955570449.davem@davemloft.net>
References: <1471884674-22709-1-git-send-email-saeedm@mellanox.com>
        <20160822.101128.1274162717645753985.davem@davemloft.net>
        <CALzJLG-eucDbJc=eo4HPvqnw-nvoXXAR1vsGPts8WFP3NR5T+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, dledford@redhat.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, leonro@mellanox.com,
        talal@mellanox.com, matanb@mellanox.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753468AbcHVStE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:49:04 -0400
In-Reply-To: <CALzJLG-eucDbJc=eo4HPvqnw-nvoXXAR1vsGPts8WFP3NR5T+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Mon, 22 Aug 2016 20:56:43 +0300

> Technical question though. Do i need to create a new tag for the new
> pull request? I mean, should the tag always point to the "up to" patch
> in the pull request? or can I just use the same tag for the new pull
> request with different "up to" commit ?

Since you're obviously not going to be asking me to pull the same
set of changes, the tag by definition will have to be different.
