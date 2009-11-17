From: David Miller <davem@davemloft.net>
Subject: Re: Shared i2c adapter locking
Date: Tue, 17 Nov 2009 06:13:55 -0800 (PST)
Message-ID: <20091117.061355.205349414.davem@davemloft.net>
References: <20091117103554.03971b2f@hyperion.delvare>
	<20091117.035147.80164577.davem@davemloft.net>
	<1258464774.2732.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khali@linux-fr.org, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	mika.kuoppala@nokia.com, linux-i2c@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752695AbZKQONl@vger.kernel.org>
In-Reply-To: <1258464774.2732.6.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Nov 2009 13:32:54 +0000

> You will need to merge Linus's tree into net-next-2.6 and resolve the
> conflict by applying Jean's changes to drivers/net/sfc/falcon_boards.c.

Ok, I'll sort this out after I next push to Linus, thanks!
