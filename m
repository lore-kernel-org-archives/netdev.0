From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH -next] net: sched: choke: remove some dead code
Date: Mon, 3 Apr 2017 20:37:29 +0200
Message-ID: <20170403183729.GA5917@nanopsycho>
References: <20170403181629.GA22938@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170403181629.GA22938@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Apr 03, 2017 at 08:18:41PM CEST, dan.carpenter@oracle.com wrote:
>We accidentally left this dead code behind after commit 5952fde10c35
>("net: sched: choke: remove dead filter classify code").
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>

