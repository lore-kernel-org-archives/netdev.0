From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Thu, 19 Apr 2007 17:58:55 +0900 (JST)
Message-ID: <20070419.175855.130993987.yoshfuji@linux-ipv6.org>
References: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
	<20070419084412.GD521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43671 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161305AbXDSI5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 04:57:51 -0400
In-Reply-To: <20070419084412.GD521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070419084412.GD521@postel.suug.ch> (at Thu, 19 Apr 2007 10:44:12 +0200), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> 2007-04-19 15:42
> > 
> > Please consider pulling following changesets for supporting exporting
> > stats information via netlink, on top of net-2.6.22.
> 
> The netlink bits are perfectly fine, why the dependency on proc fs?

I'll follow up to eliminate such dependency afterwards.

--yoshfuji
