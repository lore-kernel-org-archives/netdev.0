From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/route.c: fix build error
Date: Thu, 31 Jul 2008 20:51:32 -0700 (PDT)
Message-ID: <20080731.205132.203087940.davem@davemloft.net>
References: <20080727213905.GA4499@elte.hu>
	<20080727214250.GA5917@elte.hu>
	<489269AB.8050706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36226
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbYHADvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:51:32 -0400
In-Reply-To: <489269AB.8050706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 01 Aug 2008 09:40:59 +0800

> Dave, the build error keeps showing several days.

I've applied Ingo's patch, thanks.
