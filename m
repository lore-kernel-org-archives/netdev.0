From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: add missing include to netdevice.h
Date: Tue, 28 Jun 2005 15:59:01 -0700 (PDT)
Message-ID: <20050628.155901.78169707.davem@davemloft.net>
References: <200506281528.08834.arnd@arndb.de>
	<200506281547.04620.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, linuxppc64-dev@ozlabs.org,
	netdev@vger.kernel.org, utz.bacher@de.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262214AbVF1XCR@vger.kernel.org>
To: arnd@arndb.de
In-Reply-To: <200506281547.04620.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 28 Jun 2005 15:47:03 +0200

> linux/etherdevice.h can't be included standalone at the moment, which
> is required in order to sort the header files in the recommended
> alphabetic order. This patch fixes that and is needed to build spider_net.
> 
> Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

Applied, thanks a lot Arnd.
