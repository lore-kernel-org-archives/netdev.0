From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AX25] missplaced sock_put(sk)
Date: Thu, 26 Aug 2010 14:09:52 -0700 (PDT)
Message-ID: <20100826.140952.70208303.davem@davemloft.net>
References: <4C76C1C8.6060007@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, bpidoux@free.fr
To: f6bvp@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4C76C1C8.6060007@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard F6BVP <f6bvp@free.fr>
Date: Thu, 26 Aug 2010 21:34:32 +0200

> [PATCH] [AX25] missplaced sock_put(sk)
> 
> This patch moves a missplaced sock_put(sk) after
> bh_unlock_sock(sk)
> like in other parts of AX25 driver.
> 
> Bernard Pidoux

Please resubmit this with a proper "Signed-off-by: " tag
as-per Documentation/SubmittingPatches
