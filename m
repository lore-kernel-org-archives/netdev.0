From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/6] Mellanox 100G mlx5 DCBX CEE and
 firmware support
Date: Wed, 07 Sep 2016 13:27:03 -0700 (PDT)
Message-ID: <20160907.132703.969714617324713560.davem@davemloft.net>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
        <CALzJLG89HjLC9hOR3g2g-SLYyV1K=wM=rHcwv7C=dex1VCOUFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, huyn@mellanox.com,
        ogerlitz@mellanox.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbcIGU1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:27:41 -0400
In-Reply-To: <CALzJLG89HjLC9hOR3g2g-SLYyV1K=wM=rHcwv7C=dex1VCOUFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Wed, 7 Sep 2016 23:16:13 +0300

> Hi Dave, Sorry to bother, but i would like to drop this series for now
> Huy is working to define and come up with a better mechanism to
> enable/disable the new DCBX hybrid mode he is adding.

I can't "just drop" any change that's in my tree already.

It is part of the permanent GIT record as I never rebase my trees for
any reason whatsoever.

So the best you can do is send me a revert patch.
