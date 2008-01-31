From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Add addrlabel subsystem.
Date: Fri, 01 Feb 2008 06:59:05 +1100 (EST)
Message-ID: <20080201.065905.61890571.yoshfuji@linux-ipv6.org>
References: <20080201.065610.16428092.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39743 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765277AbYAaT6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:58:36 -0500
In-Reply-To: <20080201.065610.16428092.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080201.065610.16428092.yoshfuji@linux-ipv6.org> (at Fri, 01 Feb 2008 06:56:10 +1100 (EST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/linux/if_addrlabel.h |   32 +++++
>  ip/Makefile                  |    2 +-
>  ip/ip.c                      |    5 +-
>  ip/ip_common.h               |    4 +
>  ip/ipaddrlabel.c             |  260 ++++++++++++++++++++++++++++++++++++++++++
>  ip/ipmonitor.c               |    4 +
>  6 files changed, 304 insertions(+), 3 deletions(-)

Sorry, "iproute2" was missing in the subject...resent.

--yoshfuji
