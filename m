From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 7 Apr 2015 09:54:29 -0700
Message-ID: <CAM_iQpVoxnL2idEOQutt=ARNWdQxipCkqqiQzW8gVFt777dgew@mail.gmail.com>
References: <20150407132136.23da9e91@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150407132136.23da9e91@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 6, 2015 at 8:21 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> net/core/fib_rules.c between commit 419df12fb5fa ("net: move
> fib_rules_unregister() under rtnl lock") from the net tree and commit
> efd7ef1c1929 ("net: Kill hold_net release_net") from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Looks correct to me.

Thanks!
