From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net : To avoid execution of extra instructions in NET RX
 path when rps_map is not set but rps_needed is true.
Date: Wed, 9 Dec 2015 11:51:53 +0100
Message-ID: <20151209105153.GC2340@nanopsycho.orion>
References: <1449657321-3797-1-git-send-email-rahul.jain@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com,
	jiri@mellanox.com, daniel@iogearbox.net,
	makita.toshiaki@lab.ntt.co.jp, noureddine@arista.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, k.ashutosh@samsung.com
To: Rahul Jain <rahul.jain@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449657321-3797-1-git-send-email-rahul.jain@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Dec 09, 2015 at 11:35:21AM CET, rahul.jain@samsung.com wrote:
>From: Ashutosh Kaushik <k.ashutosh@samsung.com>
>
>The patch fixes the issues with check of global flag "rps_needed" in RX Path (which process packets in TCP/IP stack like netif_rx and netif_receive_skb functions)

First of all, if you want people to pay attention, please have your
patch description contained within 80 cols. Thanks.
