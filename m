From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 13 Feb 2008 18:31:02 +1100 (EST)
Message-ID: <20080213.183102.71846649.yoshfuji@linux-ipv6.org>
References: <47a9fb13.01538c0a.3b80.ffff9328@mx.google.com>
	<20080207072415.GA13782@2ka.mipt.ru>
	<47AAD203.4030706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, ggriffin.kernel@gmail.com,
	alan@lxorguk.ukuu.org.uk, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46089 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756926AbYBMHaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:30:23 -0500
In-Reply-To: <47AAD203.4030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47AAD203.4030706@cosmosbay.com> (at Thu, 07 Feb 2008 10:40:19 +0100), Eric Dumazet <dada1@cosmosbay.com> says:

> [NET] IPV4: lower stack usage in cookie_hash() function
> 
> 400 bytes allocated on stack might be a litle bit too much. Using a 
> per_cpu var is more friendly.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to my inet6-2.6.26 tree.  Thanks.

--yoshfuji
