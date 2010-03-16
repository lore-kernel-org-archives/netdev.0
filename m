From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-2.6 0/3] ipv6 mcast: Introduce include/net/mld.h
 for MLD definitions.
Date: Tue, 16 Mar 2010 14:31:42 +0900
Message-ID: <4B9F17BE.9030804@linux-ipv6.org>
References: <201003160527.o2G5R4MQ010839@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36470 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933446Ab0CPFcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 01:32:05 -0400
In-Reply-To: <201003160527.o2G5R4MQ010839@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, this should have 1/3 instead of 0/3 in subject...

(2010/03/16 14:27), YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki<yoshfuji@linux-ipv6.org>
> ---
>   include/net/mld.h |   75 +++++++++++++++++++++++++++++
>   net/ipv6/mcast.c  |  135 ++++++++++++++++-------------------------------------
>   2 files changed, 115 insertions(+), 95 deletions(-)
>   create mode 100644 include/net/mld.h

--yoshfuji
