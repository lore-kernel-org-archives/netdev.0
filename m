From: David Miller <davem@davemloft.net>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 04 May 2011 12:40:53 -0700 (PDT)
Message-ID: <20110504.124053.260068550.davem@davemloft.net>
References: <20110504113351.4643a0c9@nehalam>
	<16668.1304537481@localhost>
	<20110504123738.7bb4d1ee@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, rdunlap@xenotime.net, lkml@techboom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504123738.7bb4d1ee@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 May 2011 12:37:38 -0700

> Don't use BIC, it is known to be unfair between flows.

That doesn't fix the user's bug, nothing in the kernel should causes
crashes under normal circumstances.

Please stop with this deflecting on this report and instead try to
figure out why the illegal divide happens.

Thanks.
