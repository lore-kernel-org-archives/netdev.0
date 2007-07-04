From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm 0/9] netconsole: Multiple targets and dynamic
 reconfigurability
Date: Wed, 04 Jul 2007 20:49:38 +0900
Message-ID: <468B8952.9030205@bx.jp.nec.com>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:38298 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757712AbXGDLu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 07:50:26 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,
 
At first, thank you for your helping.
I'm going to try/review your patches.

>[ I had initially thought about only modifying Keiichi's patches to
>incorporate the suggested stuff, sysfs+ioctl->configfs conversion, etc,
>but the changes became too much and I ultimately ended up rewriting the
>patchset. This also gave the flexibility to make other changes possible.
>Keiichi, Takayoshi, kindly review this, and if OK, please give your
>Signed-off-by:'s to the patches herein. ]

By the way, how can I add Signed-off-by:'s to your patches?
Should I add it to each patch and submit them to this list again?

Anybody could give me an advice?
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com
