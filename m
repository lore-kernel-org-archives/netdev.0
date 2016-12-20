From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: sch_fq: use rb_entry()
Date: Tue, 20 Dec 2016 08:38:29 -0800
Message-ID: <1482251909.1521.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
         <6aa180710d70b09d4f81d3d219b3161077e1ff11.1482204526.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6aa180710d70b09d4f81d3d219b3161077e1ff11.1482204526.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-12-20 at 22:02 +0800, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  net/sched/sch_fq.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
