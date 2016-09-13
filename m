From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v5 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 13 Sep 2016 02:01:22 +0200
Message-ID: <20160913000122.GE11685@breakpoint.cc>
References: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:60174 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751097AbcIMABa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 20:01:30 -0400
Content-Disposition: inline
In-Reply-To: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> +#define MAX_EDIT_LEN ETH_HLEN

This define is only referenced in a comment and seems unused otherwise.
