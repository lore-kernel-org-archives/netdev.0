From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next trivial] drivers/net/ipg: Remove invalid
 IPG_DDEBUG_MSG uses, neaten
Date: Tue, 30 Mar 2010 23:42:36 -0700 (PDT)
Message-ID: <20100330.234236.82716909.davem@davemloft.net>
References: <1269801345.1500.32.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269801345.1500.32.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 28 Mar 2010 11:35:45 -0700

> Some no longer valid IPG_DDEBUG_MSG uses are removed
> Validate IPG_DDEBUG_MSG arguments when not #defined
> Neaten #defines
> marco/macro typo correction
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
