From: David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access 'protocol' and
 'vlan_tci' fields
Date: Tue, 17 Mar 2015 15:06:48 -0400 (EDT)
Message-ID: <20150317.150648.1979518663453994007.davem@redhat.com>
References: <1426554362-29991-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426554362-29991-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Mon, 16 Mar 2015 18:06:02 -0700

> as a follow on to patch 70006af95515 ("bpf: allow eBPF access skb fields")
> this patch allows 'protocol' and 'vlan_tci' fields to be accessible
> from extended BPF programs.
> 
> The usage of 'protocol', 'vlan_present' and 'vlan_tci' fields is the same as
> corresponding SKF_AD_PROTOCOL, SKF_AD_VLAN_TAG_PRESENT and SKF_AD_VLAN_TAG
> accesses in classic BPF.
> 
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

Applied, thanks.
