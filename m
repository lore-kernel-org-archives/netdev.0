From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Tue, 03 Jun 2008 20:34:08 +0400
Message-ID: <1212510848.12028.0.camel@iris.sw.ru>
References: <1212491322-9161-1-git-send-email-den@openvz.org>
	 <20080603.203532.39634783.yoshfuji@linux-ipv6.org>
	 <1212493845.6499.29.camel@iris.sw.ru>
	 <20080604.012619.30196060.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37759 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbYFCQeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 12:34:22 -0400
In-Reply-To: <20080604.012619.30196060.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Denis V. Lunev <den@openvz.org>

On Wed, 2008-06-04 at 01:26 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> udp.c

