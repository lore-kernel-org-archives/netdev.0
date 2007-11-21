From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Wed, 21 Nov 2007 22:20:51 +0900 (JST)
Message-ID: <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
References: <20071121124532.GA17263@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36285 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbXKUNUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 08:20:48 -0500
In-Reply-To: <20071121124532.GA17263@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071121124532.GA17263@havoc.gtf.org> (at Wed, 21 Nov 2007 07:45:32 -0500), Jeff Garzik <jeff@garzik.org> says:

> 
> SO_NO_CHECK support for IPv6 appeared to be missing. This is presented,
> based on a reading of net/ipv4/udp.c.

Disagree. UDP checksum is mandatory in IPv6.

--yoshfuji
