From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2] netfilter: remove
 include/linux/netfilter_ipv4/ipt_addrtype.h
Date: Fri, 3 Feb 2012 09:15:11 +0100
Message-ID: <20120203081511.GD30546@Chamillionaire.breakpoint.cc>
References: <1328247626-7528-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328247626-7528-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---
>  Documentation/feature-removal-schedule.txt  |    8 --------
>  include/linux/netfilter_ipv4/Kbuild         |    1 -
>  include/linux/netfilter_ipv4/ipt_addrtype.h |   27 ---------------------------
>  3 files changed, 0 insertions(+), 36 deletions(-)
>  delete mode 100644 include/linux/netfilter_ipv4/ipt_addrtype.h

I'm fine with this going into nf-next, so
Acked-By: Florian Westphal <fw@strlen.de>

note that
include/linux/netfilter_ipv4/ipt_realm.h
include/linux/netfilter_ipv4/ipt_SAME.h

could be removed, too.
