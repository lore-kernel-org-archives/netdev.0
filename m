From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Thu, 22 Feb 2007 17:16:21 +0900 (JST)
Message-ID: <20070222.171621.103542544.yoshfuji@linux-ipv6.org>
References: <20070221.232735.107942036.davem@davemloft.net>
	<20070222.164852.47947702.yoshfuji@linux-ipv6.org>
	<20070222.001245.84975312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.jp, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57084 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbXBVIQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:16:14 -0500
In-Reply-To: <20070222.001245.84975312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070222.001245.84975312.davem@davemloft.net> (at Thu, 22 Feb 2007 00:12:45 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Thu, 22 Feb 2007 16:48:52 +0900 (JST)
> 
> > I think it's time to distribute all EXPORT_SYMBOL 
> > things in ipv6_syms.c to each file which each symbol is
> > actually defined.  Don't you think so?
> 
> I very much agree.  Let's do this in 2.6.22

Will do so.

--yoshfuji
