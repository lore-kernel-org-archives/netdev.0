From: Jan Engelhardt <jengelh@medozas.de>
Subject: nf-next: TEE and nesting
Date: Wed, 31 Mar 2010 12:38:48 +0200
Message-ID: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Hi,
>
> next on the calendar is the xt_TEE submission.
>
>
> The following changes since commit b44672889c11e13e4f4dc0a8ee23f0e64f1e57c6:
>   Jan Engelhardt (1):
>         netfilter: xtables: merge registration structure to NFPROTO_UNSPEC
>
> are available in the git repository at:
>
>   git://dev.medozas.de/linux master
>
> Jan Engelhardt (5):
>       netfilter: ipv6: move POSTROUTING invocation before fragmentation
>       net: ipv6: add IPSKB_REROUTED exclusion to NF_HOOK/POSTROUTING invocation
>       netfilter: xtables: inclusion of xt_TEE
>       netfilter: xtables2: make ip_tables reentrant
>       netfilter: xt_TEE: have cloned packet travel through Xtables too

cc'd netdev due to larger changes to the IPv6 code.
