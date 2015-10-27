From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net 2/3] ipv6: Export nf_ct_frag6_consume_orig()
Date: Tue, 27 Oct 2015 14:29:50 -0700
Message-ID: <CALnjE+q_V4fWYZe0sJvP2YQMaATK-_2Maq9wJKbs8+-m1gRf2g@mail.gmail.com>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
	<1445829710-11292-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37777 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbJ0V3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:29:51 -0400
Received: by igbhv6 with SMTP id hv6so89234712igb.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:29:50 -0700 (PDT)
In-Reply-To: <1445829710-11292-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2015 at 8:21 PM, Joe Stringer <joestringer@nicira.com> wrote:
> This is needed in openvswitch to fix an skb leak in the next patch.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
