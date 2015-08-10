From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [trivial] net:wimax: Fix doucble word "the the" in
 networking.xml
Date: Sun, 09 Aug 2015 22:44:15 -0700 (PDT)
Message-ID: <20150809.224415.1529523111525465366.davem@davemloft.net>
References: <1438833167-18798-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	netdev@vger.kernel.org, trivial@kernel.org,
	linux-kernel@vger.kernel.org, corbet@lwn.net
To: standby24x7@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbbHJFoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 01:44:16 -0400
In-Reply-To: <1438833167-18798-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>
Date: Thu,  6 Aug 2015 12:52:47 +0900

> This patch fix a double word "the the"
> in Documentation/DocBook/networking.xml and
> Documentation/DocBook/networking/API-Wimax-report-rfkill-sw.html.
> 
> These files are generated from comment in source, so I had to
> fix the typo in net/wimax/io-rfkill.c
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied to net-next, thanks.
