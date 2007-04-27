From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Fri, 27 Apr 2007 16:52:32 -0700 (PDT)
Message-ID: <20070427.165232.74560572.davem@davemloft.net>
References: <4632894D.40705@hp.com>
	<20070427.163934.106263903.davem@davemloft.net>
	<46328BB0.9030501@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lawver1@llnl.gov, mst@dev.mellanox.co.il,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757920AbXD0XwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 19:52:23 -0400
In-Reply-To: <46328BB0.9030501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 27 Apr 2007 16:48:00 -0700

> No problem - just to play whatif/devil's advocate for a bit
> though... is there any way to tie that in with the setting of
> net.ipv4.ip_forward (and/or its IPv6 counterpart)?

Even ignoring that, consider the potential issues this
kind of problem could be causing netfilter.
