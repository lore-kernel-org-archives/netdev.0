From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: CPU: 2 PID: 4277 at lib/refcount.c:186
Date: Mon, 11 Sep 2017 14:58:50 -0700
Message-ID: <1505167130.15310.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAASgV=s63Mj5Ki-ep0pUrOpGonaaOZm3TEeENk+rjxA=koxPfg@mail.gmail.com>
         <CAM_iQpWOgBNmH456cOZcz-JgOYD1-YwwE4yRuLzzd4+ZzH4ALg@mail.gmail.com>
         <1504896409.15310.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505100843.15310.113.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAASgV=txONWMR2_au12ASV40mP0mf6O=4DLoq3+FfGubqG4NQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Andrew Zhu Aday <andrew.aday@columbia.edu>
To: Shankara Pailoor <sp3485@columbia.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAASgV=txONWMR2_au12ASV40mP0mf6O=4DLoq3+FfGubqG4NQQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-09-11 at 17:43 -0400, Shankara Pailoor wrote:
> Hi Eric,
> 
> I applied your patch and I no longer observed the warning. Thanks! I
> will let you know if any further problems show up during fuzzing.

Great, I also verified this fixed the problem,  I will send the official
patch shortly.

Thanks !
