From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv4 net-next 08/10] netfilter: connlabels: Export setting
 connlabel length
Date: Thu, 20 Aug 2015 18:23:31 +0200
Message-ID: <20150820162331.GC5599@pox.localdomain>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
 <1439941188-19293-9-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439941188-19293-9-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/15 at 04:39pm, Joe Stringer wrote:
> Add functions to change connlabel length into nf_conntrack_labels.c so
> they may be reused by other modules like OVS and nftables without
> needing to jump through xt_match_check() hoops.
> 
> Suggested-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Florian Westphal <fw@strlen.de>

Acked-by: Thomas Graf <tgraf@suug.ch>
