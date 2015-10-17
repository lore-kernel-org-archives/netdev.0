From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/35] Netfilter/IPVS updates for net-next
Date: Sat, 17 Oct 2015 06:07:43 -0700 (PDT)
Message-ID: <20151017.060743.10017622911100028.davem@davemloft.net>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 17 Oct 2015 13:32:35 +0200

>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

Pablo, this gives merge conflicts.

This is the second or third time in the past few pulls from you that
there have been merge conflicts, even when I haven't made a single
change between when you sent the pull request and when I try to
integrate it into my tree.

If you can't be certain there won't be merge conflicts, do a test
pull into a clone of my tree to see what happens.

Or, if you think the merge conflict is simple enough for me to deal
with, mention and explain it in the header posting for the patch
series.

Please fix this up and resend your pull request.

Thanks.
