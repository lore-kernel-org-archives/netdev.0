From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: KASAN: use-after-free in udp_lib_get_port
Date: Wed, 19 Oct 2016 23:25:54 -0700
Message-ID: <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
         <CAM_iQpVExpqdOXZp0Lw+4Nr2_9W24P2dQFdM=EoYwBkHtwDoPw@mail.gmail.com>
         <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-19 at 23:01 +0800, Baozeng Ding wrote:
> Hello all,
> I have got some similar bugs again((on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0):


Thanks for the reports, but please there is no need to send duplicates.

I have an idea of the problem, will send a patch asap, after a bit of
sleep.
