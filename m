From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: sched: choke: remove some dead code
Date: Wed, 05 Apr 2017 06:54:27 -0700 (PDT)
Message-ID: <20170405.065427.1390314194128386572.davem@davemloft.net>
References: <20170403181629.GA22938@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@mellanox.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170403181629.GA22938@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 3 Apr 2017 21:18:41 +0300

> We accidentally left this dead code behind after commit 5952fde10c35
> ("net: sched: choke: remove dead filter classify code").
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
