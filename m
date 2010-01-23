From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/31] CAPI: Major rework, tons of bug fixes
Date: Sat, 23 Jan 2010 01:18:24 -0800 (PST)
Message-ID: <20100123.011824.39481030.davem@davemloft.net>
References: <cover.1264201406.git.jan.kiszka@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: jan.kiszka@web.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753343Ab0AWJSQ@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kiszka <jan.kiszka@web.de>
Date: Sat, 23 Jan 2010 00:03:26 +0100

> First of all sorry if I'm breaking the correct flow of ISDN patches, but
> I'm under the impression that things currently get merged directly via
> Dave, right?
> 
> This series can also be pulled from
> 
> 	git://git.kiszka.org/linux-2.6.git capi

This doesn't pull cleanly into net-next-2.6 which is where I would
be adding it.

There were a bunch of changes to the procfs code here and it conflicts
with your changes.

Please do a merge and sort things out, and then send another
pull request.

Thanks.
