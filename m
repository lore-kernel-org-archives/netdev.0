From: David Miller <davem@davemloft.net>
Subject: Re: sch_htb compile fix.
Date: Sat, 15 Jul 2006 18:19:40 -0700 (PDT)
Message-ID: <20060715.181940.104030882.davem@davemloft.net>
References: <20060715074112.GA18210@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44168
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946069AbWGPBT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 21:19:27 -0400
To: davej@redhat.com
In-Reply-To: <20060715074112.GA18210@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Sat, 15 Jul 2006 03:41:12 -0400

> net/sched/sch_htb.c: In function 'htb_change_class':
> net/sched/sch_htb.c:1605: error: expected ';' before 'do_gettimeofday'
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Thanks for catching this Dave.
