From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fix spinlock usage in HWBM
Date: Wed, 25 May 2016 12:44:41 -0700 (PDT)
Message-ID: <20160525.124441.1176382793342752625.davem@davemloft.net>
References: <1464105806-439-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, jjhiblot@traphandler.com,
	thomas.petazzoni@free-electrons.com, alior@marvell.com,
	nadavh@marvell.com, mw@semihalf.com
To: gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464105806-439-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Tue, 24 May 2016 18:03:24 +0200

> these two patches fix spinlock related issues introduced in v4.6. They
> have been reported by Russell King and Jean-Jacques Hiblot.

Series applied and queued up for -stable.
