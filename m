From: David Ahern <dsahern@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 22:14:38 -0600
Message-ID: <9c4ee119-caa7-2d50-b5f9-d94d3b63ca69@gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
 <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com>
 <CAM_iQpVwBp=11c_SQgNxdONefHfZQiyzRwb2pOGgJVECytOzgg@mail.gmail.com>
 <dece4ab2-86b0-1649-5e34-1a9fa1240792@gmail.com>
 <CAM_iQpVbcOL3BD6SkVAOFLVCX5q_OpO0vfYnwG6XE4vdJkiw5Q@mail.gmail.com>
 <79157b41-2a13-6fda-ef31-c96f16850254@gmail.com>
 <CAM_iQpU8rBnJEk7NRdJ9bBan93BpjFPeVV7Yz9QSb0O-O+=BtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpU8rBnJEk7NRdJ9bBan93BpjFPeVV7Yz9QSb0O-O+=BtQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/3/17 9:55 PM, Cong Wang wrote:
> Why not add a printk and play with my patch to see the difference?

I have other things to do. If you believe your patch fixes the problem,
send it and let Andrey verify.
