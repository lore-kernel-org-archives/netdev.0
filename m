From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2] net: inet: diag: expose sockets cgroup classid
Date: Wed, 16 Aug 2017 13:15:57 -0700
Message-ID: <CAM_iQpXCf9j6XHYFnqmb_n+aqj4_j_LO5s0rcxakdJYiJCi0oA@mail.gmail.com>
References: <20170727181352.18547-1-alexander.levin@verizon.com> <20170816201707.xbpquud3ar3uarst@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816201707.xbpquud3ar3uarst@sasha-lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2017 at 1:13 PM, Levin, Alexander (Sasha Levin)
<alexander.levin@verizon.com> wrote:
> Ping?

I guess you missed the comment saying you need to check
the return value of nla_put_u32().
