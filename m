From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [TEMPORARY] net: netfilter: IPV6 XT sockets need CONFIG_NF_DEFRAG_IPV6
Date: Thu, 29 Jan 2015 17:50:30 +0100
Message-ID: <1699413.oLnudLOjvJ@wuerfel>
References: <1513018.IdvuSAziQY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:52858 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbbA2Qul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:50:41 -0500
In-Reply-To: <1513018.IdvuSAziQY@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2015 17:18:59 Arnd Bergmann wrote:
> If IP6_NF_IPTABLES=m, NF_DEFRAG_IPV6 gets selected as a module as well
> from NETFILTER_XT_MATCH_SOCKET, so the latter cannot be built-in, or
> we get:

I messed up the subject line, the [TEMPORARY] was not meant to be
in there, and I also saw that the subject was mixed up too.

I will send it again with the proper subject.

	Arnd
