From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 5/6] Netfilter: xt_LOG: Implement ring buffer support
Date: Mon, 05 Mar 2012 21:47:28 -0500
Message-ID: <1331002048.25686.354.camel@gandalf.stny.rr.com>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
	 <1330989588-26833-6-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330989588-26833-6-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-03-06 at 00:19 +0100, Richard Weinberger wrote:
> This patch introduces NETFILTER_XT_TARGET_LOG_RING.
> It allows logging into various ring buffers which are
> represented as pipe-like files in /proc/net/netfilter/nf_log_ring/.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at> 

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
