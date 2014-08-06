From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4 v5] pktgen: Upstreaming features useful
 for xen-netback/front testing
Date: Wed, 06 Aug 2014 13:53:10 -0700 (PDT)
Message-ID: <20140806.135310.1924341636144726761.davem@davemloft.net>
References: <1407349024-2489-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407349024-2489-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 6 Aug 2014 19:17:00 +0100

> This series is my work during stressing the xen network drivers, hopefully
> others can benefit from it.
> 1/4: Filling payload with pattern, useful for checking data correctness when the
> packets travelling without checksum (~ intrahost VM-to-VM). Already sent it
> separately few times, so its version number differs
> 2/4: fine-grained buffer geometrics
> 3/4: fix UDP checksuming
> 4/4: sending TCP GSO packets. This is an RFC yet, as I'm not certain about all
> things changed here
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Zoltan, please resubmit this after the merge window closes and I re-open
the net-next tree.

Thank you.
