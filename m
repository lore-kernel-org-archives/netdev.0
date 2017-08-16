From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next repost 2/3] net/sched: Change cls_flower to
 use IDR
Date: Wed, 16 Aug 2017 10:50:37 -0700 (PDT)
Message-ID: <20170816.105037.77917843676344919.davem@davemloft.net>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
        <1502871244-19870-3-git-send-email-chrism@mellanox.com>
        <CAM_iQpXOKrT658X1ADfz=WmKryqUgzfOwUF6uTnPNG00EPOQdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrism@mellanox.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        jiri@resnulli.us, mawilcox@microsoft.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751841AbdHPRuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:50:40 -0400
In-Reply-To: <CAM_iQpXOKrT658X1ADfz=WmKryqUgzfOwUF6uTnPNG00EPOQdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Aug 2017 10:42:01 -0700

> Also, _possibly_ we may make the tc filter handle generator
> generic?

Yes, this is a good idea.
