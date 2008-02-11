From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 12 Feb 2008 03:07:41 +1100 (EST)
Message-ID: <20080212.030741.132208013.yoshfuji@linux-ipv6.org>
References: <47abe7b1.20588c0a.7013.75b7@mx.google.com>
	<47abeba8.20588c0a.7013.ffff80d3@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, johnpol@2ka.mipt.ru, alan@lxorguk.ukuu.org.uk,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ggriffin.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:45090 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755055AbYBKQHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 11:07:03 -0500
In-Reply-To: <47abeba8.20588c0a.7013.ffff80d3@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47abeba8.20588c0a.7013.ffff80d3@mx.google.com> (at Thu,  7 Feb 2008 21:49:26 -0800), Glenn Griffin <ggriffin.kernel@gmail.com> says:

> Updated to incorporate Eric's suggestion of using a per cpu buffer
> rather than allocating on the stack.  Just a two line change, but will
> resend in it's entirety.
> 
> Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>

Applied in my linux-2.6-dev tree.  Thanks.

--yoshfuji
