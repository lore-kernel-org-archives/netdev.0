From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/24] net, diet: Make RPS configurable
Date: Mon, 05 May 2014 23:14:33 -0400 (EDT)
Message-ID: <20140505.231433.1853863657752503508.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-20-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-20-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:08 -0700

> Multiple receive queues are not needed on small systems,
> so allow disabling them.

It's only enabled with SMP...

I'm really totally, and completely, convinced that you wrote this
entire patch series with your brain turned off.

I'm not applying any patch in this series Andi, come back when
you have something specific and small and reasonable to discuss,
rather than this huge patch bomb of total and complete crap.
