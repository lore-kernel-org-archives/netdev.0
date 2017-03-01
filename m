From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] iproute2: add support for invisible qdisc dumping
Date: Wed, 1 Mar 2017 10:05:06 -0800
Message-ID: <20170301100506.014447c3@xeon-e3>
References: <alpine.LSU.2.20.1702252228010.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.20.1702252228010.24579@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Feb 2017 22:29:17 +0100 (CET)
Jiri Kosina <jikos@kernel.org> wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
> kernel to perform 'full qdisc dump', as for historical reasons some of the 
> default qdiscs are being hidden by the kernel.
> 
> The command syntax is being extended by voluntary 'invisible' argument to
> 'tc qdisc show'.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Still waiting for TCA_DUMP_INVISIBLE to make it into net-next
