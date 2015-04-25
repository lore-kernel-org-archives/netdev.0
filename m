From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/21] ARCNET: com20020: remove unneeded macros
Date: Fri, 24 Apr 2015 23:59:36 -0400 (EDT)
Message-ID: <20150424.235936.1118209212526994419.davem@davemloft.net>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	<1429896055-31680-7-git-send-email-m.grzeschik@pengutronix.de>
	<1429916685.23327.32.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.grzeschik@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429916685.23327.32.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 24 Apr 2015 16:04:45 -0700

> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
>> The macros SET_SUBADR, ARCRESET, ARCRESET0, ACOMMAND, ASTATUS, AINTMASK
>> and ADIAGSTATUS are unnecessary indirections to the use of registers.
>> This patch removes them and improves the readability of the code.
> 
> This breaks compilation.
> 
> Please compile test your patches before sending them.

This makes this patch series even more unacceptable.
