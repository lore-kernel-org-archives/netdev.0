From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/atm/clip.c: fix PROC_FS=n compile
Date: Sun, 09 Jul 2006 12:13:38 -0700 (PDT)
Message-ID: <20060709.121338.15426828.davem@davemloft.net>
References: <20060708202000.GC5020@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.n
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31716
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161061AbWGITNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 15:13:02 -0400
To: bunk@stusta.de
In-Reply-To: <20060708202000.GC5020@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 8 Jul 2006 22:20:01 +0200

> This patch fixes the following compile error with CONFIG_PROC_FS=n by 
> reverting commit dcdb02752ff13a64433c36f2937a58d93ae7a19e:

Applied, thanks Adrian.
