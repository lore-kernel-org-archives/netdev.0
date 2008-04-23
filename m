From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [2.6 patch] make __ipv6_isatap_ifid() static
Date: Thu, 24 Apr 2008 01:12:12 +0900 (JST)
Message-ID: <20080424.011212.72513907.yoshfuji@linux-ipv6.org>
References: <20080421084818.GN26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: bunk@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32992 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYDWQMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 12:12:14 -0400
In-Reply-To: <20080421084818.GN26897@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080421084818.GN26897@cs181133002.pp.htv.fi> (at Mon, 21 Apr 2008 11:48:18 +0300), Adrian Bunk <bunk@kernel.org> says:

> __ipv6_isatap_ifid() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
