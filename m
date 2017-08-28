From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] RDS: make rhashtable_params const
Date: Mon, 28 Aug 2017 11:30:26 -0700 (PDT)
Message-ID: <20170828.113026.1441509858623876360.davem@davemloft.net>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
        <1503670907-23221-6-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, stephen@networkplumber.org,
        alex.aring@gmail.com, stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, santosh.shilimkar@oracle.com,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, bridge@lists.linux-foundation.org,
        linux-wpan@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1503670907-23221-6-git-send-email-bhumirks@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Fri, 25 Aug 2017 19:51:45 +0530

> Make this const as it is either used during a copy operation or passed
> to a const argument of the function rhltable_init
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
