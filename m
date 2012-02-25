From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] iptables: Merge libip6t_LOG and libipt_LOG into
 libxt_LOG
Date: Sat, 25 Feb 2012 14:38:16 +0100
Message-ID: <20120225133816.GA15864@1984>
References: <1328911856-19260-1-git-send-email-richard@nod.at>
 <1328911856-19260-2-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328911856-19260-2-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2012 at 11:10:51PM +0100, Richard Weinberger wrote:
> libip6t_LOG and libipt_LOG share a lot of common code, merge them
> to recude duplicate code.

I have applied this to the net-next branch of iptables.

See git.netfilter.org

I'll merge it to master once linux kernel 3.3 is released.

Please, send follow up patches if you find any issue. Thanks.
