From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0 of 5] IPv6: Fix temporary address support
Date: Fri, 28 Mar 2008 12:15:40 +0900 (JST)
Message-ID: <20080328.121540.18727107.yoshfuji@linux-ipv6.org>
References: <20080327175839.GB8574@ens-lyon.fr>
	<20080328.031240.97295681.yoshfuji@linux-ipv6.org>
	<20080328003221.GE8574@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55391 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbYC1DOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:14:11 -0400
In-Reply-To: <20080328003221.GE8574@ens-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080328003221.GE8574@ens-lyon.fr> (at Fri, 28 Mar 2008 01:32:21 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> Do you have an opinion about my PS (DESYNC_FACTOR not being random) ?

Oh, that's a bug ... and, max_desync_factor is not effective.

--yoshfuji
