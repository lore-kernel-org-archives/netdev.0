From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] RTPROT addition in rtnetlink.h
Date: Fri, 03 Mar 2006 18:01:50 -0800 (PST)
Message-ID: <20060303.180150.91323270.davem@davemloft.net>
References: <20060304015852.GA26183@nihil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: alpt@freaknet.org
In-Reply-To: <20060304015852.GA26183@nihil>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alpt <alpt@freaknet.org>
Date: Sat, 4 Mar 2006 02:58:52 +0100

> This patch defines the Netsukuku protocol (RTPROT_NTK) by the number
> 15 in rtnetlink.h.
> 
> The Netsukuku daemon is using the same number to mark its routes,
> you can see it here:
> http://hinezumilabs.org/cgi-bin/viewcvs.cgi/netsukuku/src/krnl_route.h?rev=HEAD&content-type=text/vnd.viewcvs-markup

Applied.

Please, next time, post patches to netdev@vger.kernel.org and provide
proper "Signed-off-by: " lines.

Thanks.
