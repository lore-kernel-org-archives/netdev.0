From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Thu, 22 Feb 2007 00:12:45 -0800 (PST)
Message-ID: <20070222.001245.84975312.davem@davemloft.net>
References: <20070221.232306.51841241.davem@davemloft.net>
	<20070221.232735.107942036.davem@davemloft.net>
	<20070222.164852.47947702.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.jp
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51068
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbXBVIMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:12:46 -0500
In-Reply-To: <20070222.164852.47947702.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 22 Feb 2007 16:48:52 +0900 (JST)

> I think it's time to distribute all EXPORT_SYMBOL 
> things in ipv6_syms.c to each file which each symbol is
> actually defined.  Don't you think so?

I very much agree.  Let's do this in 2.6.22

