From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net/sched: remove redundant null check on head
Date: Wed, 3 May 2017 16:15:33 +0200
Message-ID: <20170503141533.GC2077@nanopsycho.orion>
References: <20170503135040.32023-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170503135040.32023-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, May 03, 2017 at 03:50:40PM CEST, colin.king@canonical.com wrote:
>From: Colin Ian King <colin.king@canonical.com>
>
>head is previously null checked and so the 2nd null check on head
>is redundant and therefore can be removed.
>
>Detected by CoverityScan, CID#1399505 ("Logically dead code")
>
>Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
