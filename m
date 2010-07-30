From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH net-next 3/3] drivers/net/bfin_mac.c: Misc function
	cleanups, neatening
Date: Thu, 29 Jul 2010 20:18:24 -0400
Message-ID: <AANLkTikYn+qpDxxLeJ4eu5SsEs=7n_wAu5RzM5pZhVwU@mail.gmail.com>
References: <cover.1280447281.git.joe@perches.com> <e90ce59d7dcbbdb24e1882a4e99b0c3db2bd116a.1280447281.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e90ce59d7dcbbdb24e1882a4e99b0c3db2bd116a.1280447281.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 29, 2010 at 19:58, Joe Perches wrote:
> Use new bfin_alloc_skb to centralize skb allocations
> Add and use get_mac_addr function
> Neaten bfin_mac_init
> Neaten bfin_mac_hard_start_xmit

i'll ack the idea, but i think it better i pull these patches into the
Blackfin repo to get some real hardware testing before i forward them
back to David/netdev ...

that OK with you ?
-mike
