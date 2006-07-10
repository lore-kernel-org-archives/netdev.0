From: David Miller <davem@davemloft.net>
Subject: Re: [NETROM] adsf
Date: Mon, 10 Jul 2006 16:22:35 -0700 (PDT)
Message-ID: <20060710.162235.31259939.davem@davemloft.net>
References: <20060710231446.GA8579@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <20060710231446.GA8579@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 11 Jul 2006 00:14:46 +0100

> When establishing a new circuit in nr_rx_frame the locks are taken in a
> different order than in the rest of the stack.  This should be harmless
> but triggers lockdep.  Either way, reordering the code a little solves
> the issue.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Care to give me a better header line than "[NETROM]: adsf"? :-)

Thanks.
