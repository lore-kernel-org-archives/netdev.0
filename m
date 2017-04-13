From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Thu, 13 Apr 2017 13:58:55 +0200
Message-ID: <CAAeHK+wfBBqKGH3qHi-P33VD0LKSWQdO0vgctnZ+omWZigX3YA@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
 <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
 <CACT4Y+aWYLbu5Eq1WN_T6q_zDBUdP8wiAVJK1x1D_XspQSY-RQ@mail.gmail.com>
 <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com>
 <CAM_iQpVf=Ky+hDFj2rt8VA3Jb1dv8oLgqovYWvHxj-k8KH3XSA@mail.gmail.com>
 <CAAeHK+wYR=DnbotEu0nneEv2o8MZsStGV6MCZg_3Dy90cb0iJw@mail.gmail.com> <CAM_iQpXPFjFO2jXdPOhWejBSyR6XBXqOZpr7nfAZgJrQXR5iuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXPFjFO2jXdPOhWejBSyR6XBXqOZpr7nfAZgJrQXR5iuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 9:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Apr 12, 2017 at 5:05 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi Cong,
>>
>> I now have a reproducer for this bug (attached) and your patch fixes it.
>>
>> Could you send it?
>>
>
> Done. I verified it with your reproducer too.
>
> Thanks!

Great, thanks!
