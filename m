From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] tc: bpf: generalize pedit action
Date: Sun, 29 Mar 2015 13:27:07 -0700 (PDT)
Message-ID: <20150329.132707.569593616352388141.davem@davemloft.net>
References: <1427424837-7757-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427424837-7757-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Thu, 26 Mar 2015 19:53:57 -0700

> existing TC action 'pedit' can munge any bits of the packet.
> Generalize it for use in bpf programs attached as cls_bpf and act_bpf via
> bpf_skb_store_bytes() helper function.
> 
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

Applied, thanks Alexei.
