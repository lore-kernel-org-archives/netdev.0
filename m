From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/3] [IPV6]: Do not change protocol for UDPv6 sockets
 with pending sent data.
Date: Wed, 04 Jun 2008 21:57:38 +0900 (JST)
Message-ID: <20080604.215738.98792299.yoshfuji@linux-ipv6.org>
References: <1212580148-9885-1-git-send-email-den@openvz.org>
	<1212580148-9885-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58098 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbYFDM5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:57:00 -0400
In-Reply-To: <1212580148-9885-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212580148-9885-3-git-send-email-den@openvz.org> (at Wed,  4 Jun 2008 15:49:08 +0400), "Denis V. Lunev" <den@openvz.org> says:

> Signed-off-by: Denis V. Lunev <den@openvz.org>

applied for net-2.6 and stable, thanks.

--yoshfuji
