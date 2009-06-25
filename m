From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 17:12:46 -0700 (PDT)
Message-ID: <20090624.171246.236728523.davem@davemloft.net>
References: <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
	<20090624.164233.166634429.davem@davemloft.net>
	<1245887312.12000.543.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, nooiwa@miraclelinux.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754344AbZFYAMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 20:12:41 -0400
In-Reply-To: <1245887312.12000.543.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Jun 2009 16:48:32 -0700

> I don't know about NetworkManager, but the old ifup script will bring up
> the device, wait up to 5 seconds for link up, and then do DHCP.

I'll swallow a handful of antacid tablets and take a look at
the NM sources :-/
