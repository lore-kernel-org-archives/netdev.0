From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCHv2 net-next 4/9] netfilter: connlabels: Export setting
 connlabel length
Date: Wed, 5 Aug 2015 11:01:51 +0200
Message-ID: <20150805090151.GF20471@breakpoint.cc>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
 <1438750199-9061-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, jpettit@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, jesse@nicira.com,
	hannes@redhat.com, tgraf@noironetworks.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438750199-9061-5-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> Add functions to change connlabel length into nf_conntrack_labels.c so
> they may be reused by other modules like OVS and nftables without
> needing to jump through xt_match_check() hoops.

Looks good, thanks Joe.

Acked-by: Florian Westphal <fw@strlen.de>
