From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: ROSE: Don't dereference NULL neighbour pointer.
Date: Tue, 23 Jun 2015 03:26:42 -0700 (PDT)
Message-ID: <20150623.032642.1488831810955257141.davem@davemloft.net>
References: <20150618224652.GB17494@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	stable@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150618224652.GB17494@linux-mips.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 19 Jun 2015 00:46:53 +0200

> A ROSE socket doesn't necessarily always have a neighbour pointer so check
> if the neighbour pointer is valid before dereferencing it.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Tested-by: Bernard Pidoux <f6bvp@free.fr>
> Cc: stable@vger.kernel.org #2.6.11+

Applied, thanks Ralf.
